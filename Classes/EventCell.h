#import <UIKit/UIKit.h>
#import "TextCell.h"


@protocol EventCellDelegate
- (void)openEventItem:(id)theEventItem;
@end


@class GHEvent;

@interface EventCell : TextCell

@property(assign)id<EventCellDelegate> delegate;
@property(nonatomic,retain)GHEvent *event;
@property(nonatomic,retain)IBOutlet UIView *actionsView;
@property(nonatomic,retain)IBOutlet UILabel *dateLabel;
@property(nonatomic,retain)IBOutlet UILabel *titleLabel;
@property(nonatomic,retain)IBOutlet UIImageView *iconView;
@property(nonatomic,retain)IBOutlet UIImageView *gravatarView;
@property(nonatomic,retain)IBOutlet UIButton *repositoryButton;
@property(nonatomic,retain)IBOutlet UIButton *otherRepositoryButton;
@property(nonatomic,retain)IBOutlet UIButton *userButton;
@property(nonatomic,retain)IBOutlet UIButton *otherUserButton;
@property(nonatomic,retain)IBOutlet UIButton *organizationButton;
@property(nonatomic,retain)IBOutlet UIButton *issueButton;
@property(nonatomic,retain)IBOutlet UIButton *pullRequestButton;
@property(nonatomic,retain)IBOutlet UIButton *wikiButton;
@property(nonatomic,retain)IBOutlet UIButton *commitButton;
@property(nonatomic,retain)IBOutlet UIButton *gistButton;

- (void)markAsNew;
- (void)markAsRead;
- (IBAction)showRepository:(id)sender;
- (IBAction)showOtherRepository:(id)sender;
- (IBAction)showUser:(id)sender;
- (IBAction)showOtherUser:(id)sender;
- (IBAction)showOrganization:(id)sender;
- (IBAction)showIssue:(id)sender;
- (IBAction)showPullRequest:(id)sender;
- (IBAction)showWiki:(id)sender;
- (IBAction)showCommit:(id)sender;
- (IBAction)showGist:(id)sender;
@end