#import <HockeySDK/HockeySDK.h>
#import "iOctocat.h"
#import "IOCAvatarCache.h"
#import "GHApiClient.h"
#import "GHAccount.h"
#import "GHUser.h"
#import "GHOrganization.h"
#import "GHOrganizations.h"
#import "NSString+Extensions.h"
#import "NSDictionary+Extensions.h"
#import "MenuController.h"
#import "WebController.h"
#import "YRDropdownView.h"
#import "ECSlidingViewController.h"
#import "Orbiter.h"
#import "NSUserDefaults+GroundControl.h"
#import "NSDate+Nibware.h"

#define kClearAvatarCacheDefaultsKey @"clearAvatarCache"


@interface iOctocat () <UIApplicationDelegate, BITHockeyManagerDelegate, BITCrashManagerDelegate, BITUpdateManagerDelegate>
@property(nonatomic,strong)NSMutableDictionary *users;
@property(nonatomic,strong)NSMutableDictionary *organizations;
@property(nonatomic,strong)IBOutlet UINavigationController *menuNavController;
@property(nonatomic,strong)IBOutlet ECSlidingViewController *slidingViewController;
@end


@implementation iOctocat

+ (id)sharedInstance {
	return [[UIApplication sharedApplication] delegate];
}

- (void)dealloc {
	[self clearUserObjectCache];
}

#pragma mark Application Events

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	[self deactivateURLCache];
	[self setupHockeySDK];
	self.slidingViewController.anchorRightRevealAmount = 230;
	self.slidingViewController.underLeftViewController = self.menuNavController;
	[self.window makeKeyAndVisible];
	return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[self checkAvatarCache];
	[self checkGitHubSystemStatus];
	[self contactGroundControl];
}

- (void)setCurrentAccount:(GHAccount *)account {
	[self clearUserObjectCache];
	_currentAccount = account;
	if (!self.currentAccount) {
		UIBarButtonItem *btnItem = self.menuNavController.topViewController.navigationItem.rightBarButtonItem;
		self.menuNavController.topViewController.navigationItem.rightBarButtonItem = nil;
		[self.slidingViewController anchorTopViewOffScreenTo:ECRight animateChange:YES animations:^{
			CGFloat width = UIInterfaceOrientationIsPortrait(self.menuNavController.interfaceOrientation) ? self.window.frame.size.width :
				self.window.frame.size.height;
			CGRect viewFrame = self.menuNavController.view.frame;
			viewFrame.size.width = width;
			self.menuNavController.view.frame = viewFrame;
			self.slidingViewController.underLeftWidthLayout = ECFullWidth;
		} onComplete:^{
			[self.slidingViewController setTopViewController:nil];
			self.menuNavController.topViewController.navigationItem.rightBarButtonItem = btnItem;
		}];
	} else if (self.currentAccount.user.isAuthenticated) {
		MenuController *menuController = [[MenuController alloc] initWithUser:self.currentAccount.user];
		[self.menuNavController popToRootViewControllerAnimated:NO];
		[self.menuNavController pushViewController:menuController animated:YES];
	}
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	BOOL isMenuVisible = [self.menuNavController.topViewController isKindOfClass:MenuController.class];
	BOOL isGitHubLink = [url.host isEqualToString:@"github.com"] || [url.host isEqualToString:@"gist.github.com"];
	if (isMenuVisible && isGitHubLink) {
		MenuController *menuController = (MenuController *)self.menuNavController.topViewController;
		[menuController openViewControllerForGitHubURL:url];
		return YES;
	} else {
		return NO;
	}
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSURL *serverURL = [NSURL URLWithString:@"https://ioctocat.com/push/"];
    Orbiter *orbiter = [[Orbiter alloc] initWithBaseURL:serverURL credential:nil];
    [orbiter registerDeviceToken:deviceToken withAlias:nil success:^(id responseObject) {
        DJLog(@"Registration Success: %@", responseObject);
    } failure:^(NSError *error) {
        DJLog(@"Registration Error: %@", error);
    }];
}

#pragma mark External resources

- (BOOL)openURL:(NSURL *)url {
	BOOL isGitHubLink = [url.host isEqualToString:@"github.com"] || [url.host isEqualToString:@"gist.github.com"];
	if (isGitHubLink) {
		WebController *webController = [[WebController alloc] initWithURL:url];
		[(UINavigationController *)self.slidingViewController.topViewController pushViewController:webController animated:YES];
		return YES;
	} else {
		return NO;
	}
}

- (void)contactGroundControl {
    #ifdef CONFIGURATION_Release
    NSURL *url = [NSURL URLWithString:@"https://ioctocat.com/app/defaults.plist"];
    #else
    NSURL *url = [NSURL URLWithString:@"https://ioctocat.com/app/defaults-beta.plist"];
    #endif
    [[NSUserDefaults standardUserDefaults] registerDefaultsWithURL:url success:^(NSDictionary *defaults) {
        DJLog(@"Defaults from GroundControl:\n\n%@", defaults);
    } failure:^(NSError *error) {
        NSLog(@"Error fetching defaults from GroundControl:\n\n%@\n\nUser info: %@", error, error.userInfo);
    }];
}

- (void)setupHockeySDK {
	NSString *path = [[NSBundle mainBundle] pathForResource:@"HockeySDK" ofType:@"plist"];
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
	NSString *betaId = [dict valueForKey:@"beta_identifier" defaultsTo:nil];
	NSString *liveId = [dict valueForKey:@"live_identifier" defaultsTo:nil];
	if (betaId || liveId) {
		[[BITHockeyManager sharedHockeyManager] configureWithBetaIdentifier:betaId liveIdentifier:liveId delegate:self];
		[[BITHockeyManager sharedHockeyManager] startManager];
	}
}

- (NSString *)customDeviceIdentifierForUpdateManager:(BITUpdateManager *)updateManager {
#ifndef CONFIGURATION_Release
	if ([[UIDevice currentDevice] respondsToSelector:@selector(uniqueIdentifier)]) {
		return [[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier)];
	}
#endif
	return nil;
}

#pragma mark Users

- (GHUser *)currentUser {
	return self.currentAccount.user;
}

- (GHUser *)userWithLogin:(NSString *)login {
	if (!login || [login isEmpty]) return nil;
	if (!self.users) self.users = [NSMutableDictionary dictionary];
	GHUser *user = self.users[login];
	if (user == nil) {
		user = [[GHUser alloc] initWithLogin:login];
		[user addObserver:self forKeyPath:kGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
		self.users[login] = user;
	}
	return user;
}

- (GHOrganization *)organizationWithLogin:(NSString *)login {
	if (!login || [login isEmpty]) return nil;
	if (!self.organizations) self.organizations = [NSMutableDictionary dictionary];
	GHOrganization *organization = self.organizations[login];
	if (organization == nil) {
		organization = [[GHOrganization alloc] initWithLogin:login];
		[organization addObserver:self forKeyPath:kGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
		self.organizations[login] = organization;
	}
	return organization;
}

- (void)clearUserObjectCache {
	for (GHOrganization *org in self.organizations.allValues) {
		[org removeObserver:self forKeyPath:kGravatarKeyPath];
	}
	self.organizations = nil;
	for (GHUser *user in self.users.allValues) {
		[user removeObserver:self forKeyPath:kGravatarKeyPath];
	}
	self.users = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kGravatarKeyPath]) {
		// might be a GHUser or GHOrganization instance,
		// both respond to gravatar, so this is okay
		GHUser *user = (GHUser *)object;
		if (user.gravatar) {
			[IOCAvatarCache cacheGravatar:user.gravatar forIdentifier:user.login];
		}
	}
}

#pragma mark Helpers

+ (void)reportError:(NSString *)title with:(NSString *)message {
	UIImage *image = [UIImage imageNamed:@"DropdownError.png"];
	UIColor *bgColor = [UIColor colorWithRed:0.592 green:0.0 blue:0.0 alpha:1.0];
	UIColor *textColor = [UIColor whiteColor];
	[YRDropdownView showDropdownInView:[iOctocat sharedInstance].window
								 title:title
								detail:message
								 image:image
							 textColor:textColor
					   backgroundColor:bgColor
							  animated:YES
							 hideAfter:5.0];
}

+ (void)reportWarning:(NSString *)title with:(NSString *)message {
	UIImage *image = [UIImage imageNamed:@"DropdownWarning.png"];
	UIColor *bgColor = [UIColor yellowColor];
	UIColor *textColor = [UIColor darkGrayColor];
	[YRDropdownView showDropdownInView:[iOctocat sharedInstance].window
								 title:title
								detail:message
								 image:image
							 textColor:textColor
					   backgroundColor:bgColor
							  animated:YES
							 hideAfter:5.0];
}

+ (void)reportLoadingError:(NSString *)message {
	[self reportError:@"Loading error" with:message];
}

- (void)checkGitHubSystemStatus {
	NSURL *apiURL = [NSURL URLWithString:@"https://status.github.com/"];
	NSString *path = @"/api/last-message.json";
	NSString *method = kRequestMethodGet;
	GHApiClient *apiClient = [[GHApiClient alloc] initWithBaseURL:apiURL];
	NSMutableURLRequest *request = [apiClient requestWithMethod:method path:path parameters:nil];
	void (^onSuccess)() = ^(NSURLRequest *request, NSHTTPURLResponse *response, id json) {
		D3JLog(@"System status request finished: %@", json);
		NSString *status = [json safeStringForKey:@"status"];
		if ([status isEqualToString:@"minor"] || [status isEqualToString:@"major"]) {
			NSString *date = [[json safeDateForKey:@"created_on"] prettyDate];
			NSString *body = [json safeStringForKey:@"body"];
			NSString *message = [NSString stringWithFormat:@"%@: %@", date, body];
			if ([status isEqualToString:@"major"]) {
				[iOctocat reportError:@"GitHub System Error" with:message];
			} else {
				[iOctocat reportWarning:@"GitHub System Warning" with:message];
			}
		}
	};
	void (^onFailure)()  = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id json) {
		D3JLog(@"System status request failed: %@", error);
	};
	D3JLog(@"System status request: %@ %@", method, path);
	AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:onSuccess failure:onFailure];
	[operation start];
}

- (void)checkAvatarCache {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:[NSDate date] forKey:kLastActivatedDateDefaulsKey];
	if ([defaults boolForKey:kClearAvatarCacheDefaultsKey]) {
		[IOCAvatarCache clearAvatarCache];
		[defaults setValue:NO forKey:kClearAvatarCacheDefaultsKey];
	}
	[defaults synchronize];
}

// NSURLCache seems to have a problem with Cache-Control="private" headers.
// Most resources of GitHubs API use this header and the response gets cached
// longer than the interval given by GitHub (in most cases 60 seconds).
// This way we lose caching, but its still better than unexpected results. 
- (void)deactivateURLCache {
	[[NSURLCache sharedURLCache] setMemoryCapacity:0];
	[[NSURLCache sharedURLCache] setDiskCapacity:0];
}

#pragma mark Autorotation

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
	return UIInterfaceOrientationMaskAll;
}

@end
