#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>


@class GHUser, LabeledCell, OrganizationCell;

@interface UserController : UITableViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
@property(nonatomic,weak)IBOutlet UIImageView *gravatarView;
@property(nonatomic,weak)IBOutlet UILabel *nameLabel;
@property(nonatomic,weak)IBOutlet UILabel *companyLabel;
@property(nonatomic,weak)IBOutlet UILabel *locationLabel;
@property(nonatomic,weak)IBOutlet UILabel *blogLabel;
@property(nonatomic,weak)IBOutlet UILabel *emailLabel;
@property(nonatomic,strong)IBOutlet UIView *tableHeaderView;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingUserCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingReposCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingOrganizationsCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noPublicReposCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noPublicOrganizationsCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *followersCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *followingCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *gistsCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *recentActivityCell;
@property(nonatomic,strong)IBOutlet LabeledCell *locationCell;
@property(nonatomic,strong)IBOutlet LabeledCell *blogCell;
@property(nonatomic,strong)IBOutlet LabeledCell *emailCell;
@property(nonatomic,strong)IBOutlet OrganizationCell *organizationCell;

+ (id)controllerWithUser:(GHUser *)theUser;
- (id)initWithUser:(GHUser *)theUser;
- (IBAction)showActions:(id)sender;
@end