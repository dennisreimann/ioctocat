#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>


@class GHOrganization, GHUser, LabeledCell, UserCell;

@interface OrganizationController : UITableViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
  @private
	GHOrganization *organization;
	IBOutlet UIView *tableHeaderView;
	IBOutlet UIImageView *gravatarView;
	IBOutlet UILabel *nameLabel;
	IBOutlet UILabel *companyLabel;
	IBOutlet UILabel *locationLabel;
	IBOutlet UILabel *blogLabel;
	IBOutlet UILabel *emailLabel;
	IBOutlet UITableViewCell *loadingOrganizationCell;
	IBOutlet UITableViewCell *loadingReposCell;
	IBOutlet UITableViewCell *loadingMembersCell;
	IBOutlet UITableViewCell *noPublicReposCell;
	IBOutlet UITableViewCell *noPublicMembersCell;
	IBOutlet LabeledCell *locationCell;
	IBOutlet LabeledCell *blogCell;
	IBOutlet LabeledCell *emailCell;
    IBOutlet UserCell *userCell;
}

+ (id)initWithOrganization:(GHOrganization *)theOrganization;
- (id)initWithOrganization:(GHOrganization *)theOrganization;
- (IBAction)showActions:(id)sender;

@end
