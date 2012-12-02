#import <UIKit/UIKit.h>

@class GHComment;

@interface CommentController : UIViewController <UITextFieldDelegate>

@property(nonatomic,weak)IBOutlet UITextView *bodyView;
@property(nonatomic,weak)IBOutlet UIBarButtonItem *postButton;
@property(nonatomic,weak)IBOutlet UIActivityIndicatorView *activityView;
@property(nonatomic,strong)GHComment *comment;
@property(nonatomic,strong)id comments;

+ (id)controllerWithComment:(GHComment *)theComment andComments:(id)theComments;
- (id)initWithComment:(GHComment *)theComment andComments:(id)theComments;
- (IBAction)postComment:(id)sender;

@end