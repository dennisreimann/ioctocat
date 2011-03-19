#import "NetworkCell.h"
#import "GHRepository.h"


@implementation NetworkCell

@synthesize repository;

- (void)dealloc {
  	[iconView release];
    [name release];
    [userName release];
    [super dealloc];    
}

- (void)setRepository:(GHRepository *)theRepo {
	[repository release];
	repository = [theRepo retain];
	name.text = repository.name;
    userName.text = repository.owner;
	NSString *icon = [NSString stringWithString:@"fork.png"];
	iconView.image = [UIImage imageNamed:icon];
}

@end
