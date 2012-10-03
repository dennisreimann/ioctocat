#import <UIKit/UIKit.h>


@class GHGist, GHUser, CommentCell;

@interface GistController : UITableViewController <UIActionSheetDelegate> {
  @private
	GHGist *gist;
	IBOutlet UIView *tableHeaderView;
	IBOutlet UIView *tableFooterView;
	IBOutlet UILabel *descriptionLabel;
	IBOutlet UILabel *numbersLabel;
	IBOutlet UILabel *ownerLabel;
	IBOutlet UITableViewCell *loadingCell;
	IBOutlet UITableViewCell *noFilesCell;
	IBOutlet UITableViewCell *loadingCommentsCell;
	IBOutlet UITableViewCell *noCommentsCell;
	IBOutlet UIImageView *iconView;
	IBOutlet CommentCell *commentCell;
}

+ (id)controllerWithGist:(GHGist *)theGist;
- (id)initWithGist:(GHGist *)theGist;
- (IBAction)showActions:(id)sender;
- (IBAction)addComment:(id)sender;

@end
