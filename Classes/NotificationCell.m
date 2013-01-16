#import "NotificationCell.h"
#import "GHNotification.h"
#import "GHRepository.h"
#import "NSDate+Nibware.h"


@implementation NotificationCell

+ (id)cell {
	return [[self.class alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kNotificationCellIdentifier];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	self.textLabel.font = [UIFont systemFontOfSize:15];
	self.detailTextLabel.font = [UIFont systemFontOfSize:13];
	self.selectionStyle = UITableViewCellSelectionStyleBlue;
	UIButton *accessoryButton = [UIButton buttonWithType:UIButtonTypeCustom];
	accessoryButton.frame = CGRectMake(12, 12, 20, 20);
	accessoryButton.adjustsImageWhenHighlighted = NO;
	[accessoryButton setBackgroundImage:[UIImage imageNamed:@"Remove@2x.png"] forState:UIControlStateNormal];
	[accessoryButton addTarget:self action:@selector(accessoryButtonTapped:withEvent:) forControlEvents:UIControlEventTouchUpInside];
	self.accessoryView = accessoryButton;
	return self;
}

- (void)setNotification:(GHNotification *)notification {
	_notification = notification;
	self.textLabel.text = notification.title;
	self.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", notification.repository.repoId, [notification.updatedAtDate prettyDate]];
	self.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"Type%@.png", notification.subjectType]];
	self.imageView.highlightedImage = [UIImage imageNamed:[NSString stringWithFormat:@"Type%@On.png", notification.subjectType]];
}

- (void)accessoryButtonTapped:(UIControl *)button withEvent:(UIEvent *)event {
    UITableView *tableView = (UITableView*)self.superview;
    NSIndexPath *indexPath = [tableView indexPathForCell:self];
    [tableView.delegate tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
}

@end