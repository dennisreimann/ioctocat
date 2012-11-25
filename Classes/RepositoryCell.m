#import "RepositoryCell.h"


@implementation RepositoryCell

+ (id)cell {
	return [self cellWithIdentifier:kRepositoryCellIdentifier];
}

+ (id)cellWithIdentifier:(id)reuseIdentifier {
	return [[[self.class alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier] autorelease];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	[super initWithStyle:style reuseIdentifier:reuseIdentifier];
	self.textLabel.font = [UIFont systemFontOfSize:16.0f];
	self.textLabel.highlightedTextColor = [UIColor whiteColor];
	self.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
	self.detailTextLabel.font = [UIFont systemFontOfSize:13.0f];
	self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	self.opaque = YES;
	return self;
}

- (void)dealloc {
	self.repository = nil;
    [super dealloc];
}

- (void)setRepository:(GHRepository *)theRepository {
	[theRepository retain];
	
	[_repository release];
	_repository = theRepository;
	
	self.imageView.image = [UIImage imageNamed:(self.repository.isPrivate ? @"private.png" : @"public.png")];
    self.textLabel.text = [NSString stringWithFormat:@"%@/%@", self.repository.owner, self.repository.name];
    self.detailTextLabel.text = [NSString stringWithFormat:@"%d stars, %d forks", self.repository.watcherCount, self.repository.forkCount];
}

- (void)hideOwner {
	self.textLabel.text = self.repository.name;
}

@end
