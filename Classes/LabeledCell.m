#import "LabeledCell.h"


@implementation LabeledCell

@synthesize label, content;

- (void)dealloc {
	[label release];
	[content release];
    [super dealloc];
}

@end
