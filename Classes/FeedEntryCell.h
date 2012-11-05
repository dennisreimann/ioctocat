#import <UIKit/UIKit.h>


@protocol FeedEntryCellDelegate
- (void)openEventItem:(id)theEventItem;
@end


@class GHFeedEntry;

@interface FeedEntryCell : UITableViewCell {
	GHFeedEntry *entry;
	id<FeedEntryCellDelegate> delegate;
  @private
	IBOutlet UIView *actionsView;
	IBOutlet UILabel *dateLabel;
	IBOutlet UILabel *titleLabel;
	IBOutlet UIImageView *iconView;
	IBOutlet UIImageView *gravatarView;
	IBOutlet UIButton *repositoryButton;
	IBOutlet UIButton *firstUserButton;
	IBOutlet UIButton *secondUserButton;
	IBOutlet UIButton *organizationButton;
	IBOutlet UIButton *issueButton;
	IBOutlet UIButton *commitButton;
	IBOutlet UIButton *gistButton;
}

@property(nonatomic,retain)GHFeedEntry *entry;
@property(assign)id<FeedEntryCellDelegate> delegate;

- (void)markAsNew;
- (void)markAsRead;
- (IBAction)showRepository:(id)sender;
- (IBAction)showFirstUser:(id)sender;
- (IBAction)showSecondUser:(id)sender;
- (IBAction)showOrganization:(id)sender;
- (IBAction)showIssue:(id)sender;
- (IBAction)showCommit:(id)sender;
- (IBAction)showGist:(id)sender;

@end
