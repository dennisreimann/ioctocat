#import "iOctocatAppDelegate.h"
#import "FeedViewController.h"
#import "GHUser.h"
#import <SystemConfiguration/SystemConfiguration.h>


@interface iOctocatAppDelegate (PrivateMethods)

- (void)displayNoConnectionView;

@end


@implementation iOctocatAppDelegate

@synthesize users;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	if (self.isDataSourceAvailable) {
		self.users = [NSMutableDictionary dictionary];
		[window addSubview:tabBarController.view];
    } else {
		[self displayNoConnectionView];
	}
}

// Use this to add credentials (for instance via email) by opening a link:
// githubauth://username:apitoken@github.com
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	if (!url) return NO;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setValue:[url user] forKey:kUsernameDefaultsKey];
	[defaults setValue:[url password] forKey:kTokenDefaultsKey];
	[defaults synchronize];
	// Inform the user
	NSString *message = [NSString stringWithFormat:@"Username: %@\nAPI Token: %@", [defaults valueForKey:kUsernameDefaultsKey], [defaults valueForKey:kTokenDefaultsKey]];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New credentials" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
	return YES;
}

- (BOOL)isDataSourceAvailable {
    static BOOL checkNetwork = YES;
    if (checkNetwork) {
        checkNetwork = NO;
		const char *hostName = "github.com";
        Boolean success;
        SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, hostName);
        SCNetworkReachabilityFlags flags;
        success = SCNetworkReachabilityGetFlags(reachability, &flags);
        isDataSourceAvailable = success && (flags & (kSCNetworkFlagsReachable)) && !(flags & kSCNetworkFlagsConnectionRequired);
        CFRelease(reachability);
    }
    return isDataSourceAvailable;
}

- (void)displayNoConnectionView {
	UIImage *noConnectionImage = [UIImage imageNamed:@"NoConnection.png"];
	UIImageView *noConnectionView = [[UIImageView alloc] initWithImage:noConnectionImage];
	CGRect noConnectionViewFrame = noConnectionView.frame;
	noConnectionViewFrame.origin = CGPointMake(0.0f, [UIApplication sharedApplication].statusBarFrame.size.height);
	noConnectionView.frame = noConnectionViewFrame;
	[window addSubview:noConnectionView];
	[noConnectionView release];
}


- (GHUser *)user {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *username = [defaults valueForKey:kUsernameDefaultsKey];
	return ([username isEqualToString:@""]) ? nil : [self userWithLogin:username];
}

- (GHUser *)userWithLogin:(NSString *)theUsername {
	GHUser *user = [users objectForKey:theUsername];
	if (user == nil) {
		user = [[[GHUser alloc] initWithLogin:theUsername] autorelease];
		[user loadUser];
		[users setObject:user forKey:theUsername];
	}
	return user;
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[users release];
	[tabBarController release];
	[window release];
	[super dealloc];
}

@end
