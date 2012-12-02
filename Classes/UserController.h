#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>


@class GHUser, LabeledCell, OrganizationCell;

@interface UserController : UITableViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property(nonatomic,weak)IBOutlet UIView *tableHeaderView;
@property(nonatomic,weak)IBOutlet UIImageView *gravatarView;
@property(nonatomic,weak)IBOutlet UILabel *nameLabel;
@property(nonatomic,weak)IBOutlet UILabel *companyLabel;
@property(nonatomic,weak)IBOutlet UILabel *locationLabel;
@property(nonatomic,weak)IBOutlet UILabel *blogLabel;
@property(nonatomic,weak)IBOutlet UILabel *emailLabel;
@property(nonatomic,weak)IBOutlet UITableViewCell *loadingUserCell;
@property(nonatomic,weak)IBOutlet UITableViewCell *loadingReposCell;
@property(nonatomic,weak)IBOutlet UITableViewCell *loadingOrganizationsCell;
@property(nonatomic,weak)IBOutlet UITableViewCell *noPublicReposCell;
@property(nonatomic,weak)IBOutlet UITableViewCell *noPublicOrganizationsCell;
@property(nonatomic,weak)IBOutlet UITableViewCell *followersCell;
@property(nonatomic,weak)IBOutlet UITableViewCell *followingCell;
@property(nonatomic,weak)IBOutlet UITableViewCell *gistsCell;
@property(nonatomic,weak)IBOutlet UITableViewCell *recentActivityCell;
@property(nonatomic,weak)IBOutlet LabeledCell *locationCell;
@property(nonatomic,weak)IBOutlet LabeledCell *blogCell;
@property(nonatomic,weak)IBOutlet LabeledCell *emailCell;
@property(nonatomic,weak)IBOutlet OrganizationCell *organizationCell;

+ (id)controllerWithUser:(GHUser *)theUser;
- (id)initWithUser:(GHUser *)theUser;
- (IBAction)showActions:(id)sender;

@end