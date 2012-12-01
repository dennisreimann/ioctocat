#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>


@class GHOrganization, GHUser, LabeledCell, UserCell;

@interface OrganizationController : UITableViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property(nonatomic,strong)IBOutlet UIView *tableHeaderView;
@property(nonatomic,strong)IBOutlet UIImageView *gravatarView;
@property(nonatomic,strong)IBOutlet UILabel *nameLabel;
@property(nonatomic,strong)IBOutlet UILabel *companyLabel;
@property(nonatomic,strong)IBOutlet UILabel *locationLabel;
@property(nonatomic,strong)IBOutlet UILabel *blogLabel;
@property(nonatomic,strong)IBOutlet UILabel *emailLabel;
@property(nonatomic,strong)IBOutlet UITableViewCell *recentActivityCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingOrganizationCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingReposCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingMembersCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noPublicReposCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noPublicMembersCell;
@property(nonatomic,strong)IBOutlet LabeledCell *locationCell;
@property(nonatomic,strong)IBOutlet LabeledCell *blogCell;
@property(nonatomic,strong)IBOutlet LabeledCell *emailCell;
@property(nonatomic,strong)IBOutlet UserCell *userCell;

+ (id)controllerWithOrganization:(GHOrganization *)theOrganization;
- (id)initWithOrganization:(GHOrganization *)theOrganization;
- (IBAction)showActions:(id)sender;

@end
