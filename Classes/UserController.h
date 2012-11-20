#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>


@class GHUser, LabeledCell, OrganizationCell;

@interface UserController : UITableViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
  @private
  GHUser *user;
  IBOutlet UIView *tableHeaderView;
  IBOutlet UIImageView *gravatarView;
  IBOutlet UILabel *nameLabel;
  IBOutlet UILabel *companyLabel;
  IBOutlet UILabel *locationLabel;
  IBOutlet UILabel *blogLabel;
  IBOutlet UILabel *emailLabel;
  IBOutlet UITableViewCell *loadingUserCell;
  IBOutlet UITableViewCell *loadingReposCell;
  IBOutlet UITableViewCell *loadingOrganizationsCell;
  IBOutlet UITableViewCell *noPublicReposCell;
  IBOutlet UITableViewCell *noPublicOrganizationsCell;
  IBOutlet UITableViewCell *followersCell;
  IBOutlet UITableViewCell *followingCell;
  IBOutlet UITableViewCell *gistsCell;
  IBOutlet UITableViewCell *recentActivityCell;
  IBOutlet LabeledCell *locationCell;
  IBOutlet LabeledCell *blogCell;
  IBOutlet LabeledCell *emailCell;
  IBOutlet OrganizationCell *organizationCell;
}

+ (id)controllerWithUser:(GHUser *)theUser;
- (id)initWithUser:(GHUser *)theUser;
- (IBAction)showActions:(id)sender;

@end