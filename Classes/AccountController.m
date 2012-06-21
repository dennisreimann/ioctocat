#import "AccountController.h"
#import "MyFeedsController.h"
#import "GHUser.h"
#import "iOctocat.h"


@implementation AccountController

@synthesize account;

- (id)initWithAccount:(GHAccount *)theAccount {
	[super initWithNibName:@"Account" bundle:nil];
	self.account = theAccount;
	return self;
}

- (void)dealloc {
	[feedController release], feedController = nil;
	[super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[feedController setupFeeds];
}

@end
