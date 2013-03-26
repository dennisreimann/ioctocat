#import <HockeySDK/HockeySDK.h>
#import "iOctocat.h"
#import "IOCApiClient.h"
#import "IOCAvatarCache.h"
#import "IOCDefaultsPersistence.h"
#import "IOCAuthenticationService.h"
#import "GHOAuthClient.h"
#import "GHUserObjectsRepository.h"
#import "GHAccount.h"
#import "GHUser.h"
#import "GHOrganization.h"
#import "GHOrganizations.h"
#import "GHNotifications.h"
#import "NSString+Extensions.h"
#import "NSDictionary+Extensions.h"
#import "MenuController.h"
#import "WebController.h"
#import "YRDropdownView.h"
#import "ECSlidingViewController.h"
#import "NSDate+Nibware.h"
#import "NSURL+Extensions.h"
#import "MAXStatusWindow.h"


#define kClearAvatarCacheDefaultsKey @"clearAvatarCache"
#define kUserNotificationsCountKeyPath @"user.notifications.unreadCount"


@interface iOctocat () <UIApplicationDelegate, BITHockeyManagerDelegate, BITCrashManagerDelegate, BITUpdateManagerDelegate>
@property(nonatomic,strong)NSMutableArray *accounts;
@property(nonatomic,strong)IBOutlet UINavigationController *menuNavController;
@property(nonatomic,strong)IBOutlet ECSlidingViewController *slidingViewController;
@property(nonatomic,strong)UIView *statusView;
@property(nonatomic,strong)MAXStatusWindow *statusWindow;
@end


@implementation iOctocat

+ (instancetype)sharedInstance {
	return (iOctocat *)UIApplication.sharedApplication.delegate;
}

- (UIView *)statusView {
    if (!_statusView) {
        CGRect windowFrame = [_window convertRect:UIApplication.sharedApplication.statusBarFrame fromWindow:nil];
        CGRect viewFrame = [_window.rootViewController.view convertRect:windowFrame fromView:nil];
        UIView *statusView = [[UIView alloc] initWithFrame:viewFrame];
        statusView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
        _statusView = statusView;
    }
    if (!_statusView.superview) {
        [_window.rootViewController.view addSubview:_statusView];
    } else {
        [_window.rootViewController.view bringSubviewToFront:_statusView];
    }
    return _statusView;
}

- (MAXStatusWindow *)statusWindow {
    if (!_statusWindow) {
        MAXStatusWindow *statusWindow = [[MAXStatusWindow alloc] initWithFrame:UIApplication.sharedApplication.statusBarFrame];
        [statusWindow addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)]];
        statusWindow.windowLevel = UIWindowLevelStatusBar + 1.0f;
        _statusWindow = statusWindow;
    }
    return _statusWindow;
}

- (void)handleTapGesture:(UITapGestureRecognizer *)tapGesture {
    if (tapGesture.state == UIGestureRecognizerStateEnded) {
        [self checkGitHubSystemStatus:YES];
    }
}

#pragma mark Application Events

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.deviceToken = @"";
    [UIApplication.sharedApplication setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [self registerForRemoteNotifications];
    [self deactivateURLCache];
    [self setupHockeySDK];
    [self setupAccounts];
    [self setupSlidingViewController];
    [self.window makeKeyAndVisible];
    NSDictionary *remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotification) [self application:application didReceiveRemoteNotification:remoteNotification];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if ([IOCDefaultsPersistence grantedRemoteNotificationsPermission]) {
        // Reregister for remote notifications so that we always deal
        // with fresh data like the current device token and badge
        [self registerForRemoteNotifications];
    }
	[self checkAvatarCache];
    [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? [self checkGitHubSystemStatus:YES] : [self checkGitHubSystemStatus:NO];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // store the fact that the user granted remote notifications access
    [IOCDefaultsPersistence storeRemoteNotificationsPermission:@YES];
    // save device token for later registration of accounts for that device
    NSString *alias = self.accounts.count > 0 ? [(GHAccount *)self.accounts[0] accountId] : nil;
	[IOCApiClient.sharedInstance registerPushNotificationsForDevice:deviceToken alias:alias success:^(id responseObject) {
        DJLog(@"Remote Notifications Registration Success: %@", responseObject);
		self.deviceToken = [responseObject safeStringForKey:@"token"];
    } failure:^(NSError *error) {
        DJLog(@"Remote Notifications Registration Error: %@", error);
    }];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)remoteNotification {
    if (application.applicationState == UIApplicationStateActive) {
        // TODO: Figure out a way to handle incoming remote
        // notifications when the app is in foreground
        return;
    }
    NSDictionary *info = [remoteNotification safeDictForKey:@"ioc"];
    NSString *login = [info safeStringForKey:@"a"];
    NSString *endpoint = [info safeStringForKey:@"b"];
    GHAccount *account = [self accountWithLogin:login endpoint:endpoint];
    if (!account) {
        NSString *actualEndpoint = endpoint.isEmpty ? kGitHubComURL : endpoint;
        NSString *host = [[NSURL smartURLFromString:actualEndpoint] host];
        NSString *msg = [NSString stringWithFormat:@"Could not find account %@ for %@", login, host];
        [iOctocat reportError:@"Missing account" with:msg];
        return;
    }
    NSURL *url = [NSURL smartURLFromString:[info safeStringForKey:@"c"]];
    NSInteger notificationId = [info safeIntegerForKey:@"d"];
    // open the account respecting the current state of the app
    BOOL isMenuVisible = [self.menuNavController.topViewController isKindOfClass:MenuController.class];
    if (self.currentAccount == account && isMenuVisible) {
        // the account is already open
        MenuController *menuController = (MenuController *)self.menuNavController.topViewController;
		if (notificationId) {
            [menuController openNotificationControllerWithId:notificationId url:url];
        } else {
            [menuController openNotificationsController];
        }
    } else {
        // eventually close the old account
        if (isMenuVisible) [self.menuNavController popToRootViewControllerAnimated:NO];
        // we need to open the account
        self.currentAccount = account;
        [IOCAuthenticationService authenticateAccount:account success:^(GHAccount *account) {
            self.currentAccount = account;
            MenuController *menuController = [[MenuController alloc] initWithUser:account.user];
            if (notificationId) {
                [menuController openNotificationControllerWithId:notificationId url:url];
            } else {
                [menuController openNotificationsController];
            }
            [self.menuNavController pushViewController:menuController animated:YES];
        } failure:^(GHAccount *account) {
            [iOctocat reportError:@"Authentication failed" with:@"Please ensure that you are connected to the internet and that your credentials are correct"];
        }];
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	BOOL isMenuVisible = [self.menuNavController.topViewController isKindOfClass:MenuController.class];
	if (isMenuVisible && [self isGitHubURL:url]) {
		MenuController *menuController = (MenuController *)self.menuNavController.topViewController;
		[menuController openViewControllerForGitHubURL:url];
		return YES;
	} else {
		return NO;
	}
}

#pragma mark External resources

- (BOOL)openURL:(NSURL *)url {
    UIViewController *menuController = self.menuNavController.topViewController;
    BOOL isMenuVisible = [menuController isKindOfClass:MenuController.class];
    if (!(isMenuVisible && [self isGitHubURL:url] && [(MenuController *)menuController openViewControllerForGitHubURL:url])) {
        WebController *webController = [[WebController alloc] initWithURL:url];
        [(UINavigationController *)self.slidingViewController.topViewController pushViewController:webController animated:YES];
    }
    return YES;
}

- (void)setupHockeySDK {
#ifndef CONFIGURATION_Debug
	NSString *path = [[NSBundle mainBundle] pathForResource:@"HockeySDK" ofType:@"plist"];
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
	NSString *betaId = [dict valueForKey:@"beta_identifier" defaultsTo:nil];
	NSString *liveId = [dict valueForKey:@"live_identifier" defaultsTo:nil];
	if (betaId || liveId) {
		[[BITHockeyManager sharedHockeyManager] configureWithBetaIdentifier:betaId liveIdentifier:liveId delegate:self];
		[[BITHockeyManager sharedHockeyManager] startManager];
	}
#endif
}

- (NSString *)customDeviceIdentifierForUpdateManager:(BITUpdateManager *)updateManager {
#ifndef CONFIGURATION_Release
	if ([[UIDevice currentDevice] respondsToSelector:@selector(uniqueIdentifier)]) {
		return [[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier)];
	}
#endif
	return nil;
}

- (BOOL)isGitHubURL:(NSURL *)url {
	return [url.host isEqualToString:@"github.com"] || [url.host isEqualToString:@"gist.github.com"];
}

#pragma mark Users

- (GHUser *)currentUser {
	return self.currentAccount.user;
}

- (GHUser *)userWithLogin:(NSString *)login {
    return [self.currentAccount.userObjects userWithLogin:login];
}

- (GHOrganization *)organizationWithLogin:(NSString *)login {
    return [self.currentAccount.userObjects organizationWithLogin:login];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kUserNotificationsCountKeyPath]) {
		NSInteger unread = [change safeIntegerForKey:@"new"];
		[self setBadge:unread];
	}
}

#pragma mark Helpers

- (GHAccount *)accountWithLogin:(NSString *)login endpoint:(NSString *)endpoint {
    NSUInteger idx = [self.accounts indexOfObjectPassingTest:^(GHAccount *account, NSUInteger idx, BOOL *stop) {
        if ([login isEqualToString:account.login] && [endpoint isEqualToString:account.endpoint]) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    return (idx == NSNotFound) ? nil : self.accounts[idx];
}

- (void)setCurrentAccount:(GHAccount *)account {
	[_currentAccount removeObserver:self forKeyPath:kUserNotificationsCountKeyPath];
	_currentAccount = account;
	[_currentAccount addObserver:self forKeyPath:kUserNotificationsCountKeyPath options:NSKeyValueObservingOptionNew context:nil];
	[self setBadge:self.currentAccount.user.notifications.unreadCount];
}

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

- (void)setBadge:(NSInteger)number {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (![[defaults valueForKey:kUnreadBadgeDefaultsKey] boolValue]) number = 0;
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:number];
}

- (void)checkGitHubSystemStatus:(BOOL)report {
	NSURL *apiURL = [NSURL URLWithString:@"https://status.github.com/"];
	NSString *path = @"/api/last-message.json";
	NSString *method = kRequestMethodGet;
	GHOAuthClient *apiClient = [[GHOAuthClient alloc] initWithBaseURL:apiURL];
	NSMutableURLRequest *request = [apiClient requestWithMethod:method path:path parameters:nil];
	void (^onSuccess)() = ^(NSURLRequest *request, NSHTTPURLResponse *response, id json) {
		D3JLog(@"System status request finished: %@", json);
		NSString *status = [json safeStringForKey:@"status"];
        //switch (arc4random() % 3) {
        //    case 1:
        //        status = @"minor";
        //        break;
        //    case 2:
        //        status = @"major";
        //        break;
        //    default:
        //        break;
        //}
		if ([status isEqualToString:@"minor"] || [status isEqualToString:@"major"]) {
			NSString *date = [[json safeDateForKey:@"created_on"] prettyDate];
			NSString *body = [json safeStringForKey:@"body"];
			NSString *message = [NSString stringWithFormat:@"%@: %@", date, body];
			if ([status isEqualToString:@"major"]) {
                self.statusView.backgroundColor = [UIColor redColor];
                if (report) [iOctocat reportError:@"GitHub System Error" with:message];
			} else {
                self.statusView.backgroundColor = [UIColor yellowColor];
                if (report) [iOctocat reportWarning:@"GitHub System Warning" with:message];
			}
            self.statusWindow.hidden = NO;
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
        } else {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
            [_statusView removeFromSuperview];
            _statusWindow.hidden = YES;
        }
	};
	void (^onFailure)()  = ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id json) {
		D3JLog(@"System status request failed: %@", error);
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
        [_statusView removeFromSuperview];
        _statusWindow.hidden = YES;
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
	[[NSURLCache sharedURLCache] removeAllCachedResponses];
	[[NSURLCache sharedURLCache] setMemoryCapacity:0];
	[[NSURLCache sharedURLCache] setDiskCapacity:0];
}

- (void)setupAccounts {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	id currentData = [defaults objectForKey:kAccountsDefaultsKey];
	if ([currentData isKindOfClass:NSData.class]) {
		NSArray *currentAccounts = [NSKeyedUnarchiver unarchiveObjectWithData:currentData];
		self.accounts = [NSMutableArray arrayWithArray:currentAccounts];
	} else {
		self.accounts = currentData ? [NSMutableArray arrayWithArray:currentData] : [NSMutableArray array];
		// convert old accounts
		for (NSInteger i = 0; i < self.accounts.count; i++) {
			id currentAccount = self.accounts[i];
			if ([currentAccount isKindOfClass:NSDictionary.class]) {
				GHAccount *account = [[GHAccount alloc] initWithDict:currentAccount];
				[self.accounts replaceObjectAtIndex:i withObject:account];
			}
		}
	}
}

- (void)setupSlidingViewController {
    self.slidingViewController.anchorRightRevealAmount = 230;
    self.slidingViewController.underLeftViewController = self.menuNavController;
}

- (void)registerForRemoteNotifications {
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
}

#pragma mark Autorotation

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
	return UIInterfaceOrientationMaskAll;
}

@end
