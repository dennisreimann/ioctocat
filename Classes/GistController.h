#import <UIKit/UIKit.h>


@class GHGist, GHUser, CommentCell;

@interface GistController : UITableViewController <UIActionSheetDelegate>

@property(nonatomic,weak)IBOutlet UIView *tableHeaderView;
@property(nonatomic,weak)IBOutlet UIView *tableFooterView;
@property(nonatomic,weak)IBOutlet UILabel *descriptionLabel;
@property(nonatomic,weak)IBOutlet UILabel *numbersLabel;
@property(nonatomic,weak)IBOutlet UILabel *ownerLabel;
@property(nonatomic,weak)IBOutlet UITableViewCell *loadingCell;
@property(nonatomic,weak)IBOutlet UITableViewCell *noFilesCell;
@property(nonatomic,weak)IBOutlet UITableViewCell *loadingCommentsCell;
@property(nonatomic,weak)IBOutlet UITableViewCell *noCommentsCell;
@property(nonatomic,weak)IBOutlet UIImageView *iconView;
@property(nonatomic,weak)IBOutlet CommentCell *commentCell;

+ (id)controllerWithGist:(GHGist *)theGist;
- (id)initWithGist:(GHGist *)theGist;
- (IBAction)showActions:(id)sender;
- (IBAction)addComment:(id)sender;

@end