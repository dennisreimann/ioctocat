#import <UIKit/UIKit.h>

@class GHComment;

@interface CommentController : UIViewController <UITextFieldDelegate>

@property(nonatomic,strong)IBOutlet UITextView *bodyView;
@property(nonatomic,strong)IBOutlet UIBarButtonItem *postButton;
@property(nonatomic,strong)IBOutlet UIActivityIndicatorView *activityView;
@property(nonatomic,strong)GHComment *comment;
@property(nonatomic,strong)id comments;

+ (id)controllerWithComment:(GHComment *)theComment andComments:(id)theComments;
- (id)initWithComment:(GHComment *)theComment andComments:(id)theComments;
- (IBAction)postComment:(id)sender;

@end