#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>


@class GHOrganization, GHUser, LabeledCell, UserCell;

@interface OrganizationController : UITableViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property(nonatomic,weak)IBOutlet UIView *tableHeaderView;
@property(nonatomic,weak)IBOutlet UIImageView *gravatarView;
@property(nonatomic,weak)IBOutlet UILabel *nameLabel;
@property(nonatomic,weak)IBOutlet UILabel *companyLabel;
@property(nonatomic,weak)IBOutlet UILabel *locationLabel;
@property(nonatomic,weak)IBOutlet UILabel *blogLabel;
@property(nonatomic,weak)IBOutlet UILabel *emailLabel;
@property(nonatomic,weak)IBOutlet UITableViewCell *recentActivityCell;
@property(nonatomic,weak)IBOutlet UITableViewCell *loadingOrganizationCell;
@property(nonatomic,weak)IBOutlet UITableViewCell *loadingReposCell;
@property(nonatomic,weak)IBOutlet UITableViewCell *loadingMembersCell;
@property(nonatomic,weak)IBOutlet UITableViewCell *noPublicReposCell;
@property(nonatomic,weak)IBOutlet UITableViewCell *noPublicMembersCell;
@property(nonatomic,weak)IBOutlet LabeledCell *locationCell;
@property(nonatomic,weak)IBOutlet LabeledCell *blogCell;
@property(nonatomic,weak)IBOutlet LabeledCell *emailCell;
@property(nonatomic,weak)IBOutlet UserCell *userCell;

+ (id)controllerWithOrganization:(GHOrganization *)theOrganization;
- (id)initWithOrganization:(GHOrganization *)theOrganization;
- (IBAction)showActions:(id)sender;

@end
