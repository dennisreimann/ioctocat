#import <UIKit/UIKit.h>
#import "TextCell.h"


@protocol EventCellDelegate
- (void)openEventItem:(id)theEventItem;
@end


@class GHEvent;

@interface EventCell : TextCell

@property(weak)id<EventCellDelegate> delegate;
@property(nonatomic,strong)GHEvent *event;
@property(nonatomic,weak)IBOutlet UIView *actionsView;
@property(nonatomic,weak)IBOutlet UILabel *dateLabel;
@property(nonatomic,weak)IBOutlet UILabel *titleLabel;
@property(nonatomic,weak)IBOutlet UIImageView *iconView;
@property(nonatomic,weak)IBOutlet UIImageView *gravatarView;
@property(nonatomic,weak)IBOutlet UIButton *repositoryButton;
@property(nonatomic,weak)IBOutlet UIButton *otherRepositoryButton;
@property(nonatomic,weak)IBOutlet UIButton *userButton;
@property(nonatomic,weak)IBOutlet UIButton *otherUserButton;
@property(nonatomic,weak)IBOutlet UIButton *organizationButton;
@property(nonatomic,weak)IBOutlet UIButton *issueButton;
@property(nonatomic,weak)IBOutlet UIButton *pullRequestButton;
@property(nonatomic,weak)IBOutlet UIButton *wikiButton;
@property(nonatomic,weak)IBOutlet UIButton *commitButton;
@property(nonatomic,weak)IBOutlet UIButton *gistButton;

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