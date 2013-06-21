#import "IOCNotificationCell.h"
#import "GHNotification.h"
#import "NSDate_IOCExtensions.h"


@implementation IOCNotificationCell

+ (id)cellWithReuseIdentifier:(NSString *)reuseIdentifier {
	return [[self.class alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	self.textLabel.font = [UIFont systemFontOfSize:15];
	self.detailTextLabel.font = [UIFont systemFontOfSize:13];
	self.textLabel.backgroundColor = [UIColor clearColor];
	self.detailTextLabel.backgroundColor = [UIColor clearColor];
	self.selectionStyle = UITableViewCellSelectionStyleBlue;
	UIImage *accessoryImage = [UIImage imageNamed:@"Remove.png"];
	UIButton *accessoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
	accessoryButton.frame = CGRectMake(0, 0, accessoryImage.size.width, accessoryImage.size.height);
	accessoryButton.adjustsImageWhenHighlighted = NO;
	[accessoryButton setBackgroundImage:accessoryImage forState:UIControlStateNormal];
	[accessoryButton addTarget:self action:@selector(accessoryButtonTapped:withEvent:) forControlEvents:UIControlEventTouchUpInside];
	self.accessoryView = accessoryButton;
	self.opaque = YES;
	return self;
}

- (void)setNotification:(GHNotification *)notification {
	_notification = notification;
	self.textLabel.text = notification.title;
	self.detailTextLabel.text = [notification.updatedAt ioc_prettyDate];
	self.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Type%@.png", notification.subjectType]];
	self.imageView.highlightedImage = [UIImage imageNamed:[NSString stringWithFormat:@"Type%@On.png", notification.subjectType]];
}

- (void)accessoryButtonTapped:(UIControl *)button withEvent:(UIEvent *)event {
    UITableView *tableView = (UITableView *)self.superview;
    NSIndexPath *indexPath = [tableView indexPathForCell:self];
    [tableView.delegate tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
}

- (void)setCustomBackgroundColor:(UIColor *)color {
	if (!self.backgroundView) {
		self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
	}
	self.backgroundView.backgroundColor = color;
}

- (void)markAsNew {
	UIColor *highlightColor = [UIColor colorWithHue:0.6 saturation:0.09 brightness:1.0 alpha:1.0];
	[self setCustomBackgroundColor:highlightColor];
}

- (void)markAsRead {
	UIColor *normalColor = [UIColor whiteColor];
	[self setCustomBackgroundColor:normalColor];
}

@end