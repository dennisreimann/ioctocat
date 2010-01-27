#import "BranchCell.h"


@implementation BranchCell

@synthesize branch;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	[super initWithStyle:style reuseIdentifier:reuseIdentifier];
	self.textLabel.font = [UIFont systemFontOfSize:16.0f];
	self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	self.opaque = YES;
	return self;
}

- (void)dealloc {
	[branch release], branch = nil;
    [super dealloc];
}

- (void)setBranch:(GHBranch *)theBranch {
	[theBranch retain];
	[branch release];
	branch = theBranch;
	self.imageView.image = [UIImage imageNamed:@"commit.png"];
    self.textLabel.text = branch.name;
}

@end
