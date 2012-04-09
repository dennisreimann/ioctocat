#import "iOctocat.h"
#import "GHUser.h"
#import "GHOrganization.h"
#import "GHOrganizations.h"
#import "MyFeedsController.h"
#import "SynthesizeSingleton.h"
#import "NSString+Extensions.h"
#import "NSURL+Extensions.h"


@interface iOctocat ()
- (void)postLaunch;
- (void)authenticate;
- (void)clearAvatarCache;
@end


@implementation iOctocat

@synthesize users;
@synthesize organizations;
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
    
    // Authentication
    if (launchDefault) {
        [self authenticate];
    }
}

- (void)dealloc {
	[tabBarController release], tabBarController = nil;
	[feedController release], feedController = nil;
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
	if (!login || [login isEmpty]) {
        return nil;
    } else {
        GHUser *theUser = [self userWithLogin:login];
        theUser.resourceURL = [NSURL URLWithString:kUserAuthenticatedFormat];
        theUser.organizations.resourceURL = [NSURL URLWithString:kUserAuthenticatedOrgsFormat];
        return theUser;
    }
}

- (GHUser *)userWithLogin:(NSString *)theLogin {
	if (!theLogin || [theLogin isEmpty]) return nil;
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

- (NSString *)cachedGravatarPathForIdentifier:(NSString *)theString {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [paths objectAtIndex:0];
	NSString *imageName = [NSString stringWithFormat:@"%@.png", theString];
	return [documentsPath stringByAppendingPathComponent:imageName];
}

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

- (LoginController *)loginController {
    if (!loginController) {
        loginController = [[LoginController alloc] initWithViewController:tabBarController];
        loginController.delegate = self;
    }
    return loginController;
}

- (void)authenticate {
	if (self.currentUser.isAuthenticated) return;
    [self.loginController setUser:self.currentUser];
	[self.loginController startAuthenticating];
}

- (void)finishedAuthenticating {
	if (self.currentUser.isAuthenticated) [feedController setupFeeds];
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
    if (loginController) {
        [loginController stopAuthenticating];
    }
	[self saveLastReadingDates];
}

@end
