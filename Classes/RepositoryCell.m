#import "RepositoryCell.h"


@implementation RepositoryCell

@synthesize repository;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	[super initWithStyle:style reuseIdentifier:reuseIdentifier];
	self.textLabel.font = [UIFont systemFontOfSize:16.0f];
	self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	self.opaque = YES;
	return self;
}

- (void)dealloc {
	[repository release];
    [super dealloc];
}

- (void)setRepository:(GHRepository *)theRepository {
	[theRepository retain];
	[repository release];
	repository = theRepository;
	self.imageView.image = [UIImage imageNamed:(repository.isPrivate ? @"private.png" : @"public.png")];
    self.textLabel.text = [NSString stringWithFormat:@"%@/%@", repository.owner, repository.name];
}

- (void)hideOwner {
	self.textLabel.text = repository.name;
}

@end
