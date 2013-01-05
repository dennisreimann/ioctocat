#import <HockeySDK/HockeySDK.h>
#import "iOctocat.h"
#import "IOCAvatarCache.h"
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
	for (GHOrganization *org in self.organizations) [org removeObserver:self forKeyPath:kGravatarKeyPath];
	for (GHUser *user in self.users) [user removeObserver:self forKeyPath:kGravatarKeyPath];
}

#pragma mark Application Events

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[self setupHockeySDK];
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	self.users = [NSMutableDictionary dictionary];
	self.organizations = [NSMutableDictionary dictionary];
	self.slidingViewController.anchorRightRevealAmount = 230;
	self.slidingViewController.underLeftViewController = self.menuNavController;
	[self.window makeKeyAndVisible];
	return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:[NSDate date] forKey:kLastActivatedDateDefaulsKey];
	// Avatar cache
	if ([defaults boolForKey:kClearAvatarCacheDefaultsKey]) {
		[IOCAvatarCache clearAvatarCache];
		[defaults setValue:NO forKey:kClearAvatarCacheDefaultsKey];
	}
	[defaults synchronize];
}

- (void)setCurrentAccount:(GHAccount *)account {
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

- (void)setupHockeySDK {
	NSString *path = [[NSBundle mainBundle] pathForResource:@"HockeySDK" ofType:@"plist"];
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
	NSString *betaId = [dict valueForKey:@"beta_identifier" defaultsTo:nil];
	NSString *liveId = [dict valueForKey:@"live_identifier" defaultsTo:nil];
	if (betaId || liveId) {
		[[BITHockeyManager sharedHockeyManager] configureWithBetaIdentifier:betaId
															 liveIdentifier:liveId
																   delegate:self];
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
	GHUser *user = (self.users)[login];
	if (user == nil) {
		user = [[GHUser alloc] initWithLogin:login];
		[user addObserver:self forKeyPath:kGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
		self.users[login] = user;
	}
	return user;
}

- (GHOrganization *)organizationWithLogin:(NSString *)login {
	if (!login || [login isEmpty]) return nil;
	GHOrganization *organization = self.organizations[login];
	if (organization == nil) {
		organization = [[GHOrganization alloc] initWithLogin:login];
		[organization addObserver:self forKeyPath:kGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
		self.organizations[login] = organization;
	}
	return organization;
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
	UIImage *image = [UIImage imageNamed:@"warning.png"];
	UIColor *bgColor = [UIColor colorWithRed:0.592 green:0.0 blue:0.0 alpha:1.0];
	UIColor *textColor = [UIColor whiteColor];
	[YRDropdownView showDropdownInView:[iOctocat sharedInstance].window
								 title:title
								detail:message
								 image:image
							 textColor:textColor
					   backgroundColor:bgColor
							  animated:YES
							 hideAfter:3.0];
}

+ (void)reportLoadingError:(NSString *)message {
	[self reportError:@"Loading error" with:message];
}

+ (void)reportSuccess:(NSString *)message {
	UIImage *image = [UIImage imageNamed:@"check.png"];
	UIColor *bgColor = [UIColor colorWithRed:0.150 green:0.320 blue:0.672 alpha:1.000];
	UIColor *textColor = [UIColor whiteColor];
	[YRDropdownView showDropdownInView:[iOctocat sharedInstance].window
								 title:message
								detail:nil
								 image:image
							 textColor:textColor
					   backgroundColor:bgColor
							  animated:YES
							 hideAfter:3.0];
}

#pragma mark Autorotation

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
	return UIInterfaceOrientationMaskAll;
}

@end
