#import <HockeySDK/HockeySDK.h>
#import "iOctocat.h"
#import "IOCAvatarCache.h"
#import "GHAccount.h"
#import "GHUser.h"
#import "GHOrganization.h"
#import "GHOrganizations.h"
#import "NSString+Extensions.h"
#import "NSURL+Extensions.h"
#import "MenuController.h"
#import "WebController.h"
#import "YRDropdownView.h"
#import "ECSlidingViewController.h"

#define kClearAvatarCacheDefaultsKey @"clearAvatarCache"
#define kISO8601TimeFormat @"yyyy-MM-dd'T'HH:mm:ssz"


@interface iOctocat () <UIApplicationDelegate, BITHockeyManagerDelegate, BITCrashManagerDelegate>
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

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	[self setupHockeySDK];
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	self.users = [NSMutableDictionary dictionary];
	self.organizations = [NSMutableDictionary dictionary];
	self.slidingViewController.anchorRightRevealAmount = 270;
	self.slidingViewController.underLeftViewController = self.menuNavController;
	[self.window addGestureRecognizer:self.slidingViewController.panGesture];
	[self.window makeKeyAndVisible];
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

- (void)setCurrentAccount:(GHAccount *)theAccount {
	_currentAccount = theAccount;
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
	if (dict) {
		[[BITHockeyManager sharedHockeyManager] configureWithBetaIdentifier:dict[@"beta_identifier"]
															 liveIdentifier:dict[@"live_identifier"]
																   delegate:self];
		[[BITHockeyManager sharedHockeyManager] startManager];
	}
}

#pragma mark Users

- (GHUser *)currentUser {
	return self.currentAccount.user;
}

- (GHUser *)userWithLogin:(NSString *)theLogin {
	if (!theLogin || [theLogin isKindOfClass:[NSNull class]] || [theLogin isEmpty]) return nil;
	GHUser *user = (self.users)[theLogin];
	if (user == nil) {
		user = [[GHUser alloc] initWithLogin:theLogin];
		[user addObserver:self forKeyPath:kGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
		(self.users)[theLogin] = user;
	}
	return user;
}

- (GHOrganization *)organizationWithLogin:(NSString *)theLogin {
	if (!theLogin || [theLogin isEmpty]) return nil;
	GHOrganization *organization = (self.organizations)[theLogin];
	if (organization == nil) {
		organization = [[GHOrganization alloc] initWithLogin:theLogin];
		[organization addObserver:self forKeyPath:kGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
		(self.organizations)[theLogin] = organization;
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

+ (NSDate *)parseDate:(NSString *)string {
	if ([string isKindOfClass:[NSNull class]] || string == nil || [string isEmpty]) return nil;
	static NSDateFormatter *dateFormatter;
	if (dateFormatter == nil) dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateFormat = kISO8601TimeFormat;
	// Fix for timezone format
	if ([string hasSuffix:@"Z"]) {
		string = [[string substringToIndex:[string length]-1] stringByAppendingString:@"+0000"];
	} else if ([string length] >= 24) {
		string = [string stringByReplacingOccurrencesOfString:@":" withString:@"" options:0 range:NSMakeRange(21,4)];
	}
	NSDate *date = [dateFormatter dateFromString:string];
	return date;
}

+ (void)reportError:(NSString *)theTitle with:(NSString *)theMessage {
	UIImage *image = [UIImage imageNamed:@"warning.png"];
	UIColor *bgColor = [UIColor colorWithRed:0.592 green:0.0 blue:0.0 alpha:1.0];
	UIColor *textColor = [UIColor whiteColor];
	[YRDropdownView showDropdownInView:[iOctocat sharedInstance].window
								 title:theTitle
								detail:theMessage
								 image:image
							 textColor:textColor
					   backgroundColor:bgColor
							  animated:YES
							 hideAfter:3.0];
}

+ (void)reportLoadingError:(NSString *)theMessage {
	[self reportError:@"Loading error" with:theMessage];
}

+ (void)reportSuccess:(NSString *)theMessage {
	UIImage *image = [UIImage imageNamed:@"check.png"];
	UIColor *bgColor = [UIColor colorWithRed:0.150 green:0.320 blue:0.672 alpha:1.000];
	UIColor *textColor = [UIColor whiteColor];
	[YRDropdownView showDropdownInView:[iOctocat sharedInstance].window
								 title:theMessage
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
