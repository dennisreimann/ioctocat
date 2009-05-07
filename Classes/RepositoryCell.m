#import "RepositoryCell.h"


@implementation RepositoryCell

@synthesize repository;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
	[super initWithFrame:frame reuseIdentifier:reuseIdentifier];
	self.font = [UIFont systemFontOfSize:16.0f];
	self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	self.opaque = YES;
	return self;
}

- (void)setRepository:(GHRepository *)theRepository {
	[theRepository retain];
	[repository release];
	repository = theRepository;
	self.image = [UIImage imageNamed:(repository.isPrivate ? @"private.png" : @"public.png")];
    self.text = repository.name;
}

- (void)dealloc {
	[repository release];
    [super dealloc];
}

@end
