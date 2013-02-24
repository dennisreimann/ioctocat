#import "RepositoryCell.h"


@implementation RepositoryCell

+ (id)cell {
	return [[self.class alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kRepositoryCellIdentifier];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	self.textLabel.font = [UIFont systemFontOfSize:15];
	self.textLabel.highlightedTextColor = [UIColor whiteColor];
	self.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
	self.detailTextLabel.font = [UIFont systemFontOfSize:13];
	self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	self.opaque = YES;
	return self;
}

- (void)setRepository:(GHRepository *)repo {
	_repository = repo;
	NSString *img = @"RepoPrivate";
	if (!self.repository.isPrivate) img = self.repository.isFork ? @"RepoPublicFork" : @"RepoPublic";
	self.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", img]];
	self.imageView.highlightedImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@On.png", img]];
	self.textLabel.text = self.repository.repoId;
	self.detailTextLabel.text = [NSString stringWithFormat:@"%d stars, %d forks", self.repository.watcherCount, self.repository.forkCount];
}

- (void)hideOwner {
	self.textLabel.text = self.repository.name;
}

@end
