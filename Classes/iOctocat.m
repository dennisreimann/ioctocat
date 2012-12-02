#import "iOctocat.h"
#import "GHAccount.h"
#import "GHUser.h"
#import "GHOrganization.h"
#import "GHOrganizations.h"
#import "NSString+Extensions.h"
#import "NSURL+Extensions.h"
#import "AccountController.h"
#import "WebController.h"
#import "YRDropdownView.h"


@interface iOctocat ()
@property(nonatomic,strong)NSMutableDictionary *users;
@property(nonatomic,strong)NSMutableDictionary *organizations;

+ (NSString *)gravatarPathForIdentifier:(NSString *)theString;
- (void)clearAvatarCache;
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
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	// Go
	self.users = [NSMutableDictionary dictionary];
	[self.window setRootViewController:self.navController];
	[self.window makeKeyAndVisible];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:[NSDate date] forKey:kLastActivatedDateDefaulsKey];
	// Avatar cache
	if ([defaults boolForKey:kClearAvatarCacheDefaultsKey]) {
		[self clearAvatarCache];
		[defaults setValue:NO forKey:kClearAvatarCacheDefaultsKey];
	}
	[defaults synchronize];
}

#pragma mark External resources

- (BOOL)openURL:(NSURL *)url {
	BOOL isGitHubLink = [url.host isEqualToString:@"github.com"] || [url.host isEqualToString:@"gist.github.com"];
	if (isGitHubLink) {
		WebController *webController = [WebController controllerWithURL:url];
		[self.navController pushViewController:webController animated:YES];
		return YES;
	} else {
		return NO;
	}
}

#pragma mark Users

- (GHUser *)currentUser {
	return self.currentAccount.user;
}

- (GHUser *)userWithLogin:(NSString *)theLogin {
	if (!theLogin || [theLogin isKindOfClass:[NSNull class]] || [theLogin isEmpty]) return nil;
	GHUser *user = [self.users objectForKey:theLogin];
	if (user == nil) {
		user = [GHUser userWithLogin:theLogin];
		[user addObserver:self forKeyPath:kGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
		[self.users setObject:user forKey:theLogin];
	}
	return user;
}

- (GHOrganization *)organizationWithLogin:(NSString *)theLogin {
	if (!theLogin || [theLogin isEmpty]) return nil;
	GHOrganization *organization = [self.organizations objectForKey:theLogin];
	if (organization == nil) {
		organization = [GHOrganization organizationWithLogin:theLogin];
		[organization addObserver:self forKeyPath:kGravatarKeyPath options:NSKeyValueObservingOptionNew context:nil];
		[self.organizations setObject:organization forKey:theLogin];
	}
	return organization;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kGravatarKeyPath]) {
		// might be a GHUser or GHOrganization instance,
		// both respond to gravatar, so this is okay
		GHUser *user = (GHUser *)object;
		if (user.gravatar) {
			[iOctocat cacheGravatar:user.gravatar forIdentifier:user.login];
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

#pragma mark Avatars

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

+ (NSString *)gravatarPathForIdentifier:(NSString *)theString {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [paths objectAtIndex:0];
	NSString *imageName = [NSString stringWithFormat:@"%@.png", theString];
	return [documentsPath stringByAppendingPathComponent:imageName];
}

+ (UIImage *)cachedGravatarForIdentifier:(NSString *)theString {
	NSString *path = [self gravatarPathForIdentifier:theString];
	return [UIImage imageWithContentsOfFile:path];
}

+ (void)cacheGravatar:(UIImage *)theImage forIdentifier:(NSString *)theString {
	NSString *path = [self gravatarPathForIdentifier:theString];
	[UIImagePNGRepresentation(theImage) writeToFile:path atomically:YES];
}

#pragma mark Autorotation

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
	return UIInterfaceOrientationMaskAll;
}

@end
