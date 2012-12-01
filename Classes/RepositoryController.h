#import <UIKit/UIKit.h>


@class GHRepository, GHUser, TextCell, LabeledCell;

@interface RepositoryController : UITableViewController <UIActionSheetDelegate>

@property(nonatomic,strong)IBOutlet UIView *tableHeaderView;
@property(nonatomic,strong)IBOutlet UILabel *nameLabel;
@property(nonatomic,strong)IBOutlet UILabel *numbersLabel;
@property(nonatomic,strong)IBOutlet UILabel *ownerLabel;
@property(nonatomic,strong)IBOutlet UILabel *websiteLabel;
@property(nonatomic,strong)IBOutlet UILabel *forkLabel;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *readmeCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *issuesCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *forkCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *eventsCell;
@property(nonatomic,strong)IBOutlet UIImageView *iconView;
@property(nonatomic,strong)IBOutlet LabeledCell *ownerCell;
@property(nonatomic,strong)IBOutlet LabeledCell *websiteCell;
@property(nonatomic,strong)IBOutlet TextCell *descriptionCell;

+ (id)controllerWithRepository:(GHRepository *)theRepository;
- (id)initWithRepository:(GHRepository *)theRepository;
- (IBAction)showActions:(id)sender;

@end