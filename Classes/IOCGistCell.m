#import "IOCGistCell.h"
#import "GHGist.h"
#import "GHUser.h"
#import "NSDate_IOCExtensions.h"


@interface IOCGistCell ()
@property(nonatomic,assign)BOOL displayUser;
@end


@implementation IOCGistCell

+ (id)cellWithReuseIdentifier:(NSString *)reuseIdentifier {
	return [[self.class alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	self.textLabel.font = [UIFont systemFontOfSize:15];
	self.detailTextLabel.font = [UIFont systemFontOfSize:13];
	self.selectionStyle = UITableViewCellSelectionStyleBlue;
	self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	self.opaque = YES;
	self.displayUser = YES;
	return self;
}

- (void)setGist:(GHGist *)gist {
	_gist = gist;
	NSString *userInfo = self.displayUser && self.gist.user ? [NSString stringWithFormat:@"%@ - ", self.gist.user.login] : @"";
    // unfortunately atm the gist api does not state the fork
	// status of a gist, but in the future this might work
	NSString *img = @"GistPrivate";
	if (!self.gist.isPrivate) img = self.gist.isFork ? @"GistPublicFork" : @"GistPublic";
	self.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", img]];
	self.imageView.highlightedImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@On.png", img]];
	self.textLabel.text = gist.title;
	self.detailTextLabel.text = [NSString stringWithFormat:@"%@%@", userInfo, [gist.createdAt ioc_prettyDate]];
}

- (void)hideUser {
	self.displayUser = NO;
}

@end