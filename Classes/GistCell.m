#import "GistCell.h"
#import "GHGist.h"
#import "NSDate+Nibware.h"


@implementation GistCell

+ (id)cell {
	return [[self.class alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kGistCellIdentifier];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	self.textLabel.font = [UIFont systemFontOfSize:15];
	self.detailTextLabel.font = [UIFont systemFontOfSize:13];
	self.selectionStyle = UITableViewCellSelectionStyleBlue;
	self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	return self;
}

- (void)setGist:(GHGist *)gist {
	_gist = gist;
	self.textLabel.text = gist.title;
	self.detailTextLabel.text = [NSString stringWithFormat:@"%@, %d %@", [gist.createdAtDate prettyDate], gist.commentsCount, gist.commentsCount == 1 ? @"comment" : @"comments"];
	self.imageView.image = [UIImage imageNamed:(gist.isPrivate ? @"Private.png" : @"Public.png")];
	self.imageView.highlightedImage = [UIImage imageNamed:(gist.isPrivate ? @"PrivateOn.png" : @"PublicOn.png")];
}

@end