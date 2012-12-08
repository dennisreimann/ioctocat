#import <UIKit/UIKit.h>


@class GHGist, GHUser, CommentCell;

@interface GistController : UITableViewController <UIActionSheetDelegate>
@property(nonatomic,weak)IBOutlet UILabel *descriptionLabel;
@property(nonatomic,weak)IBOutlet UILabel *numbersLabel;
@property(nonatomic,weak)IBOutlet UILabel *ownerLabel;
@property(nonatomic,weak)IBOutlet UIImageView *iconView;
@property(nonatomic,strong)IBOutlet UIView *tableHeaderView;
@property(nonatomic,strong)IBOutlet UIView *tableFooterView;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noFilesCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *loadingCommentsCell;
@property(nonatomic,strong)IBOutlet UITableViewCell *noCommentsCell;
@property(nonatomic,strong)IBOutlet CommentCell *commentCell;

- (id)initWithGist:(GHGist *)theGist;
- (IBAction)showActions:(id)sender;
- (IBAction)addComment:(id)sender;
@end