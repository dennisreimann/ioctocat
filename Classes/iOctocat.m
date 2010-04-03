#import "iOctocat.h"
#import "MyFeedsController.h"
#import "SynthesizeSingleton.h"
#import "NSString+Extensions.h"


@interface iOctocat ()
- (void)postLaunch;
- (void)presentLogin;
- (void)dismissLogin;
- (void)showAuthenticationSheet;
- (void)dismissAuthenticationSheet;
- (void)authenticate;
- (void)proceedAfterAuthentication;
- (void)clearAvatarCache;
- (NSDateFormatter *)inputDateFormatter;
@end


static NSDateFormatter *inputDateFormatter;


@implementation iOctocat

@synthesize users;
@synthesize queue;
@synthesize lastLaunchDate;

SYNTHESIZE_SINGLETON_FOR_CLASS(iOctocat);

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	self.users = [NSMutableDictionary dictionary];
	[window addSubview:tabBarController.view];
	launchDefault = YES;
	[self performSelector:@selector(postLaunch) withObject:nil afterDelay:0.0];
}

- (void)postLaunch {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	// Launch date
	NSDate *lastLaunch = (NSDate *)[defaults valueForKey:kLaunchDateDefaultsKey];
	NSDate *nowDate = [NSDate date];
	if (!lastLaunch) lastLaunch = nowDate;
	self.lastLaunchDate = lastLaunch;
	[defaults setValue:nowDate forKey:kLaunchDateDefaultsKey];
	
	// Request queue
	NSOperationQueue *requestQueue = [[NSOperationQueue alloc] init];
	self.queue = requestQueue;
	[requestQueue release];
	
	// Avatar cache
	if ([defaults boolForKey:kClearAvatarCacheDefaultsKey]) {
		[self clearAvatarCache];
		[defaults setValue:NO forKey:kClearAvatarCacheDefaultsKey];
	}
	[defaults synchronize];
	if (launchDefault) [self authenticate];
}

- (void)dealloc {
	[tabBarController release], tabBarController = nil;
	[feedController release], feedController = nil;
	[authView release], authView = nil;
	[authSheet release], authSheet = nil;
	[window release], window = nil;
	[users release], users = nil;
	[queue release], queue = nil;
	
	[super dealloc];
}

- (NSDateFormatter *)inputDateFormatter {
	if (!inputDateFormatter) {
		inputDateFormatter = [[NSDateFormatter alloc] init];
		inputDateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ"; 
	}
	return inputDateFormatter;
}

- (NSDate *)parseDate:(NSString *)theString {
	return [[self inputDateFormatter] dateFromString:theString];
}

- (UIView *)currentView {
    return tabBarController.modalViewController ? tabBarController.modalViewController.view : tabBarController.view;
}

- (GHUser *)currentUser {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *login = [defaults valueForKey:kUsernameDefaultsKey];
	return (!login || [login isEmpty]) ? nil : [self userWithLogin:login];
}

- (GHUser *)userWithLogin:(NSString *)theUsername {
	if (!theUsername || [theUsername isEqualToString:@""]) return nil;
	GHUser *user = [users objectForKey:theUsername];
	if (user == nil) {
		user = [GHUser userWithLogin:theUsername];
		[users setObject:user forKey:theUsername];
	}
	return user;
}

- (void)clearAvatarCache {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [paths objectAtIndex:0];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *documents = [fileManager contentsOfDirectoryAtPath:documentsPath error:NULL];
	for (NSString *path in documents) {
		if ([path hasSuffix:@".png"]) {
			NSString *imagePath = [documentsPath stringByAppendingPathComponent:path];
			[fileManager removeItemAtPath:imagePath error:NULL];
		}
	}
}

#pragma mark Authentication

// Use this to add credentials (for instance via email) by opening a link:
// <githubauth://LOGIN:TOKEN@github.com>
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	if (!url || [[url user] isEmpty] || [[url password] isEmpty]) return NO;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setValue:[url user] forKey:kUsernameDefaultsKey];
	[defaults setValue:[url password] forKey:kTokenDefaultsKey];
	[defaults synchronize];
	// Inform the user
	NSString *message = [NSString stringWithFormat:@"Username: %@\nAPI Token: %@", [defaults valueForKey:kUsernameDefaultsKey], [defaults valueForKey:kTokenDefaultsKey]];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New credentials" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
	return YES;
}

- (void)authenticate {
	if (self.currentUser.isAuthenticated) return;
	if (!self.currentUser) {
		[self presentLogin];
	} else {
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSString *token = [defaults valueForKey:kTokenDefaultsKey];
		[self.currentUser addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
		[self.currentUser authenticateWithToken:token];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (self.currentUser.isLoading) {
		[self showAuthenticationSheet];
	} else if (self.currentUser.isLoaded) {
		[self dismissAuthenticationSheet];
		[self.currentUser removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
		if (self.currentUser.isAuthenticated) {
			[self proceedAfterAuthentication];
		} else {
			[self presentLogin];
			[self.loginController failWithMessage:@"Please ensure that you are connected to the internet and that your login and API token are correct"];
		}
	}
}

- (LoginController *)loginController {
	return (LoginController *)tabBarController.modalViewController ;
}

- (void)presentLogin {
	if (self.loginController) return;
	LoginController *loginController = [[LoginController alloc] initWithTarget:self andSelector:@selector(authenticate)];
	[tabBarController presentModalViewController:loginController animated:YES];
	[loginController release];
}

- (void)dismissLogin {
	if (self.loginController) [tabBarController dismissModalViewControllerAnimated:YES];
}

- (void)showAuthenticationSheet {
	authSheet = [[UIActionSheet alloc] initWithTitle:@"\n\n" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	UIView *currentView = tabBarController.modalViewController ? tabBarController.modalViewController.view : tabBarController.view;
	[authSheet addSubview:authView];
	[authSheet showInView:currentView];
	[authSheet release];
}

- (void)dismissAuthenticationSheet {
	[authSheet dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)proceedAfterAuthentication {
	[self dismissLogin];
	[feedController setupFeeds];
}

@end
