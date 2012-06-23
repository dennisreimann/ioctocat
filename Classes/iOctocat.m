#import "iOctocat.h"
#import "GHAccount.h"
#import "GHUser.h"
#import "GHOrganization.h"
#import "GHOrganizations.h"
#import "SynthesizeSingleton.h"
#import "NSString+Extensions.h"
#import "NSURL+Extensions.h"
#import "ASINetworkQueue.h"
#import "AccountController.h"


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

SYNTHESIZE_SINGLETON_FOR_CLASS(iOctocat);

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	// Beware of zombies!
	if(getenv("NSZombieEnabled") || getenv("NSAutoreleaseFreedObjectCheckEnabled")) {
		JLog(@"NSZombieEnabled/NSAutoreleaseFreedObjectCheckEnabled enabled!");
	}
	
	// Avatar cache
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if ([defaults boolForKey:kClearAvatarCacheDefaultsKey]) {
		[self clearAvatarCache];
		[defaults setValue:NO forKey:kClearAvatarCacheDefaultsKey];
		[defaults synchronize];
	}
	
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	
	// Go
	self.users = [NSMutableDictionary dictionary];
	[window addSubview:navController.view];
	[window makeKeyAndVisible];
}

- (void)dealloc {
	[accountController release], accountController = nil;
	[navController release], navController = nil;
	[window release], window = nil;
	[users release], users = nil;
	[super dealloc];
}

#pragma mark Users

- (GHUser *)currentUser {
	return self.currentAccount.user;
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

+ (void)alert:(NSString *)theTitle with:(NSString *)theMessage {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:theTitle
													message:theMessage
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
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

#pragma mark Network

+ (ASINetworkQueue *)queue {
	static ASINetworkQueue *queue;
	if (queue == nil) {
		queue = [[ASINetworkQueue queue] retain];
		[queue go];
	}
	return queue;
}

#pragma mark Application Events

- (void)applicationDidBecomeActive:(UIApplication *)application {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:[NSDate date] forKey:kLastActivatedDateDefaulsKey];
	[defaults synchronize];
}

@end
