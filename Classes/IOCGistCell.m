#import "IOCGistCell.h"
#import "GHGist.h"
#import "GHUser.h"
#import "NSDate+Nibware.h"


@interface IOCGistCell ()
@property(nonatomic,assign)BOOL displayUser;
@end


@implementation IOCGistCell

+ (id)cell {
	return [[self.class alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kGistCellIdentifier];
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
	self.textLabel.text = gist.title;
	self.detailTextLabel.text = [NSString stringWithFormat:@"%@%@", userInfo, [gist.createdAtDate prettyDate]];
	self.imageView.image = [UIImage imageNamed:(gist.isPrivate ? @"Private.png" : @"Public.png")];
	self.imageView.highlightedImage = [UIImage imageNamed:(gist.isPrivate ? @"PrivateOn.png" : @"PublicOn.png")];
}

- (void)hideUser {
	self.displayUser = NO;
}

@end