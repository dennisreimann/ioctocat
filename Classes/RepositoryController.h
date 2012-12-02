#import <UIKit/UIKit.h>


@class GHRepository, GHUser, TextCell, LabeledCell;

@interface RepositoryController : UITableViewController <UIActionSheetDelegate>

@property(nonatomic,weak)IBOutlet UIView *tableHeaderView;
@property(nonatomic,weak)IBOutlet UILabel *nameLabel;
@property(nonatomic,weak)IBOutlet UILabel *numbersLabel;
@property(nonatomic,weak)IBOutlet UILabel *ownerLabel;
@property(nonatomic,weak)IBOutlet UILabel *websiteLabel;
@property(nonatomic,weak)IBOutlet UILabel *forkLabel;
@property(nonatomic,weak)IBOutlet UITableViewCell *loadingCell;
@property(nonatomic,weak)IBOutlet UITableViewCell *readmeCell;
@property(nonatomic,weak)IBOutlet UITableViewCell *issuesCell;
@property(nonatomic,weak)IBOutlet UITableViewCell *forkCell;
@property(nonatomic,weak)IBOutlet UITableViewCell *eventsCell;
@property(nonatomic,weak)IBOutlet UIImageView *iconView;
@property(nonatomic,weak)IBOutlet LabeledCell *ownerCell;
@property(nonatomic,weak)IBOutlet LabeledCell *websiteCell;
@property(nonatomic,weak)IBOutlet TextCell *descriptionCell;

+ (id)controllerWithRepository:(GHRepository *)theRepository;
- (id)initWithRepository:(GHRepository *)theRepository;
- (IBAction)showActions:(id)sender;

@end