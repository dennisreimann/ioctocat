#import "IOCRepositoryCell.h"
#import "NSString_IOCExtensions.h"


@implementation IOCRepositoryCell

+ (id)cellWithReuseIdentifier:(NSString *)reuseIdentifier {
	return [[self.class alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
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
    NSString *language = [self.repository.language ioc_isEmpty] ? @"" : [NSString stringWithFormat:@"%@ - ", self.repository.language];
	if (!self.repository.isPrivate) img = self.repository.isFork ? @"RepoPublicFork" : @"RepoPublic";
	self.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", img]];
	self.imageView.highlightedImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@On.png", img]];
	self.textLabel.text = self.repository.repoId;
    self.detailTextLabel.text = [NSString stringWithFormat:@"%@%d %@, %d %@", language, self.repository.watcherCount, self.repository.watcherCount == 1 ? @"star" : @"stars", self.repository.forkCount, self.repository.forkCount == 1 ? @"fork" : @"forks"];
}

- (void)hideOwner {
	self.textLabel.text = self.repository.name;
}

@end
