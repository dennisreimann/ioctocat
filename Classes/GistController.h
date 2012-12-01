#import <UIKit/UIKit.h>


@class GHGist, GHUser, CommentCell;

@interface GistController : UITableViewController <UIActionSheetDelegate>

@property(nonatomic,strong)IBOutlet UIView *tableHeaderView;
@property(nonatomic,strong)IBOutlet UIView *tableFooterView;
@property(nonatomic,strong)IBOutlet UILabel *descriptionLabel;
@property(nonatomic,strong)IBOutlet UILabel *numbersLabel;
@property(nonatomic,strong)IBOutlet UILabel *ownerLabel;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noFilesCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingCommentsCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noCommentsCell;
@property(nonatomic,strong)IBOutlet UIImageView *iconView;
@property(nonatomic,strong)IBOutlet CommentCell *commentCell;

+ (id)controllerWithGist:(GHGist *)theGist;
- (id)initWithGist:(GHGist *)theGist;
- (IBAction)showActions:(id)sender;
- (IBAction)addComment:(id)sender;

@end