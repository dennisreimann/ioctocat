#import <UIKit/UIKit.h>


@class GHComment;

@interface CommentController : UIViewController <UITextFieldDelegate>
@property(nonatomic,weak)IBOutlet UITextView *bodyView;
@property(nonatomic,strong)IBOutlet UIBarButtonItem *postButton;
@property(nonatomic,strong)IBOutlet UIActivityIndicatorView *activityView;

+ (id)controllerWithComment:(GHComment *)theComment andComments:(id)theComments;
- (id)initWithComment:(GHComment *)theComment andComments:(id)theComments;
- (IBAction)postComment:(id)sender;
@end