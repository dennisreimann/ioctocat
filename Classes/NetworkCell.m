#import "NetworkCell.h"
#import "GHNetwork.h"

@implementation NetworkCell

@synthesize network;

- (void)setNetwork:(GHNetwork *)theNetwork {
	[network release];
	network = [theNetwork retain];
	name.text = network.name;
    userName.text = network.user.login;
	NSString *icon = [NSString stringWithString:@"fork.png"];
	iconView.image = [UIImage imageNamed:icon];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:object change:change context:context {
}

- (void)dealloc {
  	[iconView release];
    [name release];
    [userName release];
    [super dealloc];    
}


@end
