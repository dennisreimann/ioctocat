#import "iOctocat.h"
#import "GHAccount.h"
#import "GHUser.h"
#import "GHOrganization.h"
#import "GHOrganizations.h"
#import "NSString+Extensions.h"
#import "NSURL+Extensions.h"
#import "AccountController.h"
#import "WBErrorNoticeView.h"
#import "WBSuccessNoticeView.h"


@interface iOctocat ()
@property(nonatomic,retain)NSMutableDictionary *users;
@property(nonatomic,retain)NSMutableDictionary *organizations;

+ (NSString *)gravatarPathForIdentifier:(NSString *)theString;
- (void)clearAvatarCache;
@end


@implementation iOctocat

@synthesize users;
@synthesize organizations;
@synthesize currentAccount;
@synthesize window;
@synthesize navController;
@synthesize accountController;

+ (id)sharedInstance {
    return [[UIApplication sharedApplication] delegate];
}

- (void)dealloc {
	[accountController release], accountController = nil;
	[navController release], navController = nil;
	[window release], window = nil;
	[users release], users = nil;
	[super dealloc];
}

#pragma mark Application Events

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	// Beware of zombies!
	if(getenv("NSZombieEnabled") || getenv("NSAutoreleaseFreedObjectCheckEnabled")) {
		JLog(@"NSZombieEnabled/NSAutoreleaseFreedObjectCheckEnabled enabled!");
	}
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	// Go
	self.users = [NSMutableDictionary dictionary];
	[window setRootViewController:navController];
	[window makeKeyAndVisible];
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

#pragma mark Users

- (GHUser *)currentUser {
	return self.currentAccount.user;
}

- (GHUser *)userWithLogin:(NSString *)theLogin {
	if (!theLogin || [theLogin isKindOfClass:[NSNull class]] || [theLogin isEmpty]) return nil;
	GHUser *user = [users objectForKey:theLogin];
	if (user == nil) {
		user = [GHUser userWithLogin:theLogin];
		[users setObject:user forKey:theLogin];
	}
	return user;
}

- (GHOrganization *)organizationWithLogin:(NSString *)theLogin {
	if (!theLogin || [theLogin isEmpty]) return nil;
	GHOrganization *organization = [organizations objectForKey:theLogin];
	if (organization == nil) {
		organization = [GHOrganization organizationWithLogin:theLogin];
		[organizations setObject:organization forKey:theLogin];
	}
	return organization;
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
	WBErrorNoticeView *notice = [WBErrorNoticeView errorNoticeInView:[iOctocat sharedInstance].window
															   title:theTitle
															 message:theMessage];
	notice.originY = [[UIApplication sharedApplication] statusBarFrame].size.height;
	[notice show];
}

+ (void)reportLoadingError:(NSString *)theMessage {
	[self reportError:@"Loading error" with:theMessage];
}

+ (void)reportSuccess:(NSString *)theMessage {
	WBSuccessNoticeView *notice = [WBSuccessNoticeView successNoticeInView:[iOctocat sharedInstance].window
																	 title:theMessage];
	notice.originY = [[UIApplication sharedApplication] statusBarFrame].size.height;
	[notice show];
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
