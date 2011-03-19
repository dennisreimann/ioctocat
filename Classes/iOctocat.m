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
@end


@implementation iOctocat

@synthesize users;
@synthesize didBecomeActiveDate;

SYNTHESIZE_SINGLETON_FOR_CLASS(iOctocat);

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	// Beware of zombies!
	if(getenv("NSZombieEnabled") || getenv("NSAutoreleaseFreedObjectCheckEnabled")) {
		JLog(@"NSZombieEnabled/NSAutoreleaseFreedObjectCheckEnabled enabled!");
	}
	self.users = [NSMutableDictionary dictionary];
	[window addSubview:tabBarController.view];
	launchDefault = YES;
	[self performSelector:@selector(postLaunch) withObject:nil afterDelay:0.0];
}

- (void)postLaunch {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDate *nowDate = [NSDate date];

	// Did-become-active date
	self.didBecomeActiveDate = nowDate;
	
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
	
	[super dealloc];
}

- (UIView *)currentView {
    return tabBarController.modalViewController ? tabBarController.modalViewController.view : tabBarController.view;
}

- (GHUser *)currentUser {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *login = [defaults valueForKey:kLoginDefaultsKey];
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

- (NSInteger)gravatarSize {
	UIScreen *mainScreen = [UIScreen mainScreen];
	CGFloat deviceScale = ([mainScreen respondsToSelector:@selector(scale)]) ? [mainScreen scale] : 1.0;
	NSInteger size = kImageGravatarMaxLogicalSize * MAX(deviceScale, 1.0);
	return size;
}

- (NSString *)cachedGravatarPathForIdentifier:(NSString *)theString {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [paths objectAtIndex:0];
	NSString *imageName = [NSString stringWithFormat:@"%@.png", theString];
	return [documentsPath stringByAppendingPathComponent:imageName];
}

+ (NSDate *)parseDate:(NSString *)string withFormat:(NSString *)theFormat {
	static NSDateFormatter *dateFormatter;
	if (dateFormatter == nil) dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = theFormat;
    // Fix for timezone format
    string = [string stringByReplacingOccurrencesOfString:@":" withString:@"" options:0 range:NSMakeRange(21,4)];
	NSDate *date = [dateFormatter dateFromString:string];
	return date;
}

#pragma mark Network

+ (ASINetworkQueue *)queue {
	static ASINetworkQueue *queue;
	if (queue == nil) {
		queue = [[ASINetworkQueue queue] retain];
		[queue go];
	}
	return queue;
}

#pragma mark Authentication

// Use this to add credentials (for instance via email) by opening a link:
// <githubauth://LOGIN:TOKEN@github.com>
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	if (!url || [[url user] isEmpty] || [[url password] isEmpty]) return NO;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setValue:[url user] forKey:kLoginDefaultsKey];
	[defaults setValue:[url password] forKey:kTokenDefaultsKey];
	[defaults synchronize];
	// Inform the user
	NSString *message = [NSString stringWithFormat:@"Username: %@\nAPI Token: %@", [defaults valueForKey:kLoginDefaultsKey], [defaults valueForKey:kTokenDefaultsKey]];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New credentials" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
	// Set the values
	self.loginController.loginField.text = [defaults valueForKey:kLoginDefaultsKey];
	self.loginController.tokenField.text = [defaults valueForKey:kTokenDefaultsKey];
	return YES;
}

- (void)authenticate {
	if (self.currentUser.isAuthenticated) return;
	if (!self.currentUser) {
		[self presentLogin];
	} else {
		[self.currentUser addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
		[self.currentUser loadData];
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
	return (LoginController *)tabBarController.modalViewController;
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

#pragma mark Persistent State

- (NSDate *)lastReadingDateForURL:(NSURL *)url {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *key = [kLastReadingDateURLDefaultsKeyPrefix stringByAppendingString:[url absoluteString]];
	NSObject *object = [userDefaults valueForKey:key];
	DJLog(@"%@: %@", key, object);
	if (![object isKindOfClass:[NSDate class]]) {
		return nil;
	}
	return (NSDate *)object;
}

- (void)setLastReadingDate:(NSDate *)date forURL:(NSURL *)url {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *key = [kLastReadingDateURLDefaultsKeyPrefix stringByAppendingString:[url absoluteString]];
	DJLog(@"%@: %@", key, date);
	[userDefaults setValue:date forKey:key];
}

- (void)saveLastReadingDates {
	[[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark Application Events

- (void)applicationDidBecomeActive:(UIApplication *)application {
	NSDate *nowDate = [NSDate date];
	self.didBecomeActiveDate = nowDate;
	if ([tabBarController selectedIndex] == 0) {
		[feedController refreshCurrentFeedIfRequired];
	}
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[self saveLastReadingDates];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	[self saveLastReadingDates];
}

@end
