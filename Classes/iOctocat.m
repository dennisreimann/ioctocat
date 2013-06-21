#import <AudioToolbox/AudioServices.h>
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
#import "NSString_IOCExtensions.h"
#import "NSDictionary_IOCExtensions.h"
#import "IOCMenuController.h"
#import "IOCWebController.h"
#import "YRDropdownView.h"
#import "ECSlidingViewController.h"
#import "NSDate_IOCExtensions.h"
#import "NSURL_IOCExtensions.h"
#import "GHSystemStatusService.h"


@interface iOctocat () <UIApplicationDelegate, BITHockeyManagerDelegate, BITCrashManagerDelegate, BITUpdateManagerDelegate>
@property(nonatomic,strong)NSMutableArray *accounts;
@property(nonatomic,strong)UIView *statusView;
@property(nonatomic,strong)UIWindow *statusWindow;
@property(nonatomic,strong)IBOutlet UINavigationController *menuNavController;
@property(nonatomic,strong)IBOutlet ECSlidingViewController *slidingViewController;
@end


@implementation iOctocat

static NSString *const ClearAvatarCacheDefaultsKey = @"clearAvatarCache";
static NSString *const MigratedAvatarCacheDefaultsKey = @"migratedAvatarCache";

+ (instancetype)sharedInstance {
	return (iOctocat *)UIApplication.sharedApplication.delegate;
}

#pragma mark Application Events

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.deviceToken = @"";
    [UIApplication.sharedApplication setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [self registerDefaultsFromSettingsBundle];
    [self deactivateURLCache];
    [self setupHockeySDK];
    [self setupAccounts];
    [self setupAvatarCache];
    [self setupSlidingViewController];
    [self.window makeKeyAndVisible];
    // remote notifications
    NSDictionary *remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotification) [self application:application didReceiveRemoteNotification:remoteNotification];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [IOCDefaultsPersistence updateLastActivationDate];
    [self setBadge:0];
    [self syncDeviceInformationWithServer];
    // if the current account is a GitHub.com account, check the system status
    if (self.currentAccount.isGitHub) {
        BOOL isPhone = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone;
        [self checkGitHubSystemStatus:isPhone report:!isPhone];
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    UIViewController *menuController = self.menuNavController.topViewController;
    BOOL isMenuVisible = [menuController isKindOfClass:IOCMenuController.class];
    if (isMenuVisible && url.ioc_isGitHubURL && [(IOCMenuController *)menuController openViewControllerForGitHubURL:url]) {
		return YES;
	}
    return NO;
}

- (void)application:(UIApplication *)application willChangeStatusBarFrame:(CGRect)newStatusBarFrame {
    _statusWindow.frame = newStatusBarFrame;
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect windowFrame = [_statusView.window convertRect:newStatusBarFrame fromWindow:nil];
        CGRect viewFrame = [_statusView.superview convertRect:windowFrame fromView:nil];
        _statusView.frame = viewFrame;
    });
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [self syncDeviceInformationWithServer];
}

#pragma mark Remote Notifications

- (void)registerForRemoteNotifications {
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // store the fact that the user granted remote notifications access
    [IOCDefaultsPersistence storeRemoteNotificationsPermission:@YES];
    // save device token for later registration of accounts for that device
    self.deviceToken = [IOCApiClient normalizeDeviceToken:deviceToken];
    NSString *alias = self.accounts.count > 0 ? [(GHAccount *)self.accounts[0] accountId] : nil;
	[IOCApiClient.sharedInstance registerPushNotificationsForDevice:deviceToken alias:alias success:^(id responseObject) {
        self.deviceToken = [responseObject ioc_stringForKey:@"token"];
    } failure:nil];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    D3JLog(@"Registering device for push notifications failed: %@", error);
    // only display the error to the user when the initial registeration fails.
    // do not display the error in case the permission has been granted before
    // and this is a failed attempt of re-registration.
    if ([IOCDefaultsPersistence grantedRemoteNotificationsPermission]) return;
    NSString *message = [NSString stringWithFormat:@"Could not register for remote notifications: %@", error.localizedDescription];
    [iOctocat reportError:@"Registration failed" with:message];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)remoteNotification {
    DJLog(@"Remote Notifications received: %@", remoteNotification);
    if (application.applicationState == UIApplicationStateActive) {
        [self reportNotification:remoteNotification];
    } else {
        [self openNotification:remoteNotification];
    }
}

- (void)reportNotification:(NSDictionary *)remoteNotification {
    NSDictionary *aps = [remoteNotification ioc_dictForKey:@"aps"];
    NSDictionary *ioc = [remoteNotification ioc_dictForKey:@"ioc"];
    NSString *login = [ioc ioc_stringForKey:@"a"];
    NSString *type = [ioc ioc_stringOrNilForKey:@"e"];
    NSString *sound = [aps ioc_stringOrNilForKey:@"sound"];
    NSString *message = [aps ioc_stringForKey:@"alert"];
    NSString *title = self.accounts.count > 1 ? login : @"New notification";
    if (!type) type = @"Notifications";
    if (sound) [iOctocat playSound:sound];
    NSString *imageName = [NSString stringWithFormat:@"Type%@On.png", type];
    UIImage *image = [UIImage imageNamed:imageName];
    // present dropdown
    YRDropdownView *dropdown = [YRDropdownView dropdownInView:iOctocat.sharedInstance.window title:title detail:message image:image animated:YES];
    dropdown.titleTextColor = dropdown.textColor = [UIColor whiteColor];
    dropdown.titleTextShadowColor = dropdown.textShadowColor = [UIColor darkGrayColor];
    dropdown.backgroundColors = @[
                                  [UIColor colorWithRed:0.000 green:0.265 blue:0.509 alpha:1.000],
                                  [UIColor colorWithRed:0.000 green:0.509 blue:0.747 alpha:1.000],
                                  [UIColor colorWithRed:0.055 green:0.400 blue:0.698 alpha:1.000],
                                  [UIColor colorWithRed:0.034 green:0.332 blue:0.586 alpha:1.000]];
    dropdown.backgroundColorPositions = @[@0.0f, @0.05, @0.985, @1.0f];
    dropdown.hideAfter = 6.5;
    dropdown.tapBlock= ^{ [self openNotification:remoteNotification]; };
    [YRDropdownView presentDropdown:dropdown];
}

- (void)openNotification:(NSDictionary *)remoteNotification {
    NSDictionary *ioc = [remoteNotification ioc_dictForKey:@"ioc"];
    NSString *login = [ioc ioc_stringForKey:@"a"];
    NSString *endpoint = [ioc ioc_stringForKey:@"b"];
    if ([endpoint ioc_isEmpty]) endpoint = kGitHubComURL;
    GHAccount *account = [self accountWithLogin:login endpoint:endpoint];
    if (!account) {
        NSString *host = [[NSURL ioc_smartURLFromString:endpoint] host];
        NSString *msg = [NSString stringWithFormat:@"Could not find account %@ for %@", login, host];
        [iOctocat reportError:@"Missing account" with:msg];
        return;
    }
    NSURL *url = [NSURL ioc_smartURLFromString:[ioc ioc_stringForKey:@"c"]];
    NSInteger notificationId = [ioc ioc_integerForKey:@"d"];
    // open the account respecting the current state of the app
    BOOL isMenuVisible = [self.menuNavController.topViewController isKindOfClass:IOCMenuController.class];
    if (self.currentAccount == account && isMenuVisible) {
        // the account is already open
        IOCMenuController *menuController = (IOCMenuController *)self.menuNavController.topViewController;
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
            IOCMenuController *menuController = [[IOCMenuController alloc] initWithUser:account.user];
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

#pragma mark Users

- (void)setCurrentAccount:(GHAccount *)account {
    _currentAccount = account;
    // if the current account is a GitHub.com account, check the system status
    if (_currentAccount.isGitHub) {
        BOOL isPhone = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone;
        [self checkGitHubSystemStatus:isPhone report:!isPhone];
    } else {
        [self resetStatusBar];
    }
}

- (GHUser *)currentUser {
	return self.currentAccount.user;
}

- (GHUser *)userWithLogin:(NSString *)login {
    return [self.currentAccount.userObjects userWithLogin:login];
}

- (GHOrganization *)organizationWithLogin:(NSString *)login {
    return [self.currentAccount.userObjects organizationWithLogin:login];
}

#pragma mark Helpers

// taken from http://ijure.org/wp/archives/179
- (void)registerDefaultsFromSettingsBundle {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if (!settingsBundle) return;
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:preferences.count];
    for (NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if (key) {
            // check if value is present in userDefaults and set it in case it is not
            id currentObject = [defaults objectForKey:key];
            if (currentObject == nil) {
                id objectToSet = [prefSpecification objectForKey:@"DefaultValue"];
                [defaultsToRegister setObject:objectToSet forKey:key];
            }
        }
    }
    [defaults registerDefaults:defaultsToRegister];
    [defaults synchronize];
}

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

- (void)setBadge:(NSInteger)number {
	if (![[[NSUserDefaults standardUserDefaults] valueForKey:kUnreadBadgeDefaultsKey] boolValue]) number = 0;
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:number];
}

- (void)setupAvatarCache {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:ClearAvatarCacheDefaultsKey]) {
        [IOCAvatarCache clearAvatarCache];
        [defaults setValue:@NO forKey:ClearAvatarCacheDefaultsKey];
    }
    [IOCAvatarCache ensureAvatarCacheDirectory];
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

- (BOOL)openURL:(NSURL *)url {
    UIViewController *menuController = self.menuNavController.topViewController;
    BOOL isMenuVisible = [menuController isKindOfClass:IOCMenuController.class];
    if (isMenuVisible && url.ioc_isGitHubURL && [(IOCMenuController *)menuController openViewControllerForGitHubURL:url]) {
        return YES;
    } else {
        NSString *scheme = url.scheme;
        if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]) {
            IOCWebController *webController = [[IOCWebController alloc] initWithURL:url];
            [(UINavigationController *)self.slidingViewController.topViewController pushViewController:webController animated:YES];
            return YES;
        }
    }
    return NO;
}

- (void)syncDeviceInformationWithServer {
    if ([IOCDefaultsPersistence grantedRemoteNotificationsPermission]) {
        // Reregister for remote notifications so that we always deal
        // with fresh data like the current device token and badge
        [self registerForRemoteNotifications];
    }
}

#pragma mark Dropdowns

+ (void)reportLoadingError:(NSString *)message {
	[self reportError:@"Loading error" with:message];
}

+ (void)reportError:(NSString *)title with:(NSString *)message {
	UIImage *image = [UIImage imageNamed:@"DropdownError.png"];
	YRDropdownView *dropdown = [YRDropdownView dropdownInView:iOctocat.sharedInstance.window title:title detail:message image:image animated:YES];
	dropdown.titleTextColor = dropdown.textColor = [UIColor whiteColor];
	dropdown.backgroundColors = @[
                               [UIColor colorWithRed:0.243 green:0.020 blue:0.039 alpha:1.000],
                               [UIColor colorWithRed:0.780 green:0.141 blue:0.196 alpha:1.000],
                               [UIColor colorWithRed:0.600 green:0.071 blue:0.004 alpha:1.000],
                               [UIColor colorWithRed:0.525 green:0.055 blue:0.000 alpha:1.000]];
	dropdown.backgroundColorPositions = @[@0.0f, @0.03, @0.95, @1.0f];
	dropdown.hideAfter = 5.0;
    [YRDropdownView presentDropdown:dropdown];
}

+ (void)reportWarning:(NSString *)title with:(NSString *)message {
	UIImage *image = [UIImage imageNamed:@"DropdownWarning.png"];
	YRDropdownView *dropdown = [YRDropdownView dropdownInView:iOctocat.sharedInstance.window title:title detail:message image:image animated:YES];
    dropdown.titleTextColor = dropdown.textColor = [UIColor darkGrayColor];
    dropdown.backgroundColors = @[
                                  [UIColor colorWithRed:0.773 green:0.682 blue:0.000 alpha:1.000],
                                  [UIColor colorWithRed:0.875 green:0.820 blue:0.000 alpha:1.000],
                                  [UIColor colorWithRed:0.992 green:0.980 blue:0.000 alpha:1.000],
                                  [UIColor colorWithRed:0.906 green:0.894 blue:0.000 alpha:1.000]];
	dropdown.backgroundColorPositions = @[@0.0f, @0.01, @0.95, @1.0f];
    dropdown.hideAfter = 5.0;
    [YRDropdownView presentDropdown:dropdown];
}

+ (void)hideDropdown {
    [YRDropdownView hideDropdownInView:iOctocat.sharedInstance.window];
}

#pragma mark GitHub System Status

- (UIView *)statusView {
    if (!_statusView) {
        CGRect windowFrame = [_window convertRect:UIApplication.sharedApplication.statusBarFrame fromWindow:nil];
        CGRect viewFrame = [_window.rootViewController.view convertRect:windowFrame fromView:nil];
        UIView *statusView = [[UIView alloc] initWithFrame:viewFrame];
        [_window.rootViewController.view addSubview:statusView];
        _statusView = statusView;
    }
    return _statusView;
}

- (UIWindow *)statusWindow {
    if (!_statusWindow) {
        UIWindow *statusWindow = [[UIWindow alloc] initWithFrame:UIApplication.sharedApplication.statusBarFrame];
        [statusWindow addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)]];
        statusWindow.windowLevel = UIWindowLevelStatusBar;
        _statusWindow = statusWindow;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidBecomeKey:) name:UIWindowDidBecomeKeyNotification object:_statusWindow];
    }
    return _statusWindow;
}

- (void)checkGitHubSystemStatus:(BOOL)isPhone report:(BOOL)report {
	[GHSystemStatusService checkWithMajor:^(NSString *message) {
        if (isPhone) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
            self.statusView.backgroundColor = [UIColor redColor];
            self.statusWindow.hidden = NO;
        }
        if (report) [iOctocat reportError:@"GitHub System Error" with:message];
    } minor:^(NSString *message) {
        if (report) [iOctocat reportWarning:@"GitHub System Warning" with:message];
        if (isPhone) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];
            self.statusView.backgroundColor = [UIColor yellowColor];
            self.statusWindow.hidden = NO;
        }
    } good:^(NSString *message) {
        if (isPhone) [self resetStatusBar];
    } failure:^(NSError *error) {
        if (isPhone) [self resetStatusBar];
    }];
}

- (void)resetStatusBar {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIWindowDidBecomeKeyNotification object:self.statusWindow];
    self.statusWindow = nil;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    [_statusView removeFromSuperview];
    self.statusView = nil;
}

- (void)bringStatusViewToFront {
    [_statusView.superview bringSubviewToFront:_statusView];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)tapGesture {
    if (tapGesture.state == UIGestureRecognizerStateEnded) {
        if ([YRDropdownView isCurrentlyShowing]) {
            [iOctocat hideDropdown];
        } else {
            [self checkGitHubSystemStatus:YES report:YES];
        }
    }
}

- (void)windowDidBecomeKey:(NSNotification *)notification {
    [self.window makeKeyWindow];
}

#pragma mark Sound

void SystemSoundCallback(SystemSoundID ssID, void *clientData) {
    AudioServicesRemoveSystemSoundCompletion(ssID);
    AudioServicesDisposeSystemSoundID(ssID);
}

+ (void)playSound:(NSString *)fileName {
    NSURL *url = [[NSBundle mainBundle] URLForResource:fileName withExtension:nil];
    if (url) {
        SystemSoundID ssID;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &ssID);
        AudioServicesAddSystemSoundCompletion(ssID, NULL, NULL, SystemSoundCallback, NULL);
        AudioServicesPlayAlertSound(ssID);
    }
}

#pragma mark Hockey

- (void)setupHockeySDK {
#ifndef CONFIGURATION_Debug
	NSString *path = [[NSBundle mainBundle] pathForResource:@"HockeySDK" ofType:@"plist"];
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
	NSString *betaId = [dict ioc_valueForKey:@"beta_identifier" defaultsTo:nil];
	NSString *liveId = [dict ioc_valueForKey:@"live_identifier" defaultsTo:nil];
	if (betaId || liveId) {
        [BITHockeyManager.sharedHockeyManager configureWithBetaIdentifier:betaId liveIdentifier:liveId delegate:self];
        [BITHockeyManager.sharedHockeyManager startManager];
        BITHockeyManager.sharedHockeyManager.feedbackManager.requireUserName = BITFeedbackUserDataElementRequired;
        BITHockeyManager.sharedHockeyManager.feedbackManager.requireUserEmail = BITFeedbackUserDataElementRequired;
	}
#endif
}

- (NSString *)userNameForHockeyManager:(BITHockeyManager *)hockeyManager componentManager:(BITHockeyBaseManager *)componentManager {
    return self.currentUser.login;
}

- (NSString *)userEmailForHockeyManager:(BITHockeyManager *)hockeyManager componentManager:(BITHockeyBaseManager *)componentManager {
    return self.currentUser.email;
}

- (NSString *)customDeviceIdentifierForUpdateManager:(BITUpdateManager *)updateManager {
#ifndef CONFIGURATION_Release
	if ([[UIDevice currentDevice] respondsToSelector:@selector(uniqueIdentifier)]) {
		return [[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier)];
	}
#endif
	return nil;
}

#pragma mark Autorotation

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
	return UIInterfaceOrientationMaskAll;
}

@end
