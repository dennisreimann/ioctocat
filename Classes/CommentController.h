#import <UIKit/UIKit.h>

@class GHComment;

@interface CommentController : UIViewController <UITextFieldDelegate> {
	IBOutlet UITextView *bodyView;
	IBOutlet UIBarButtonItem *postButton;
	IBOutlet UIActivityIndicatorView *activityView;
  @private
	GHComment *comment;
	id comments;
}

+ (id)controllerWithComment:(GHComment *)theComment andComments:(id)theComments;
- (id)initWithComment:(GHComment *)theComment andComments:(id)theComments;
- (IBAction)postComment:(id)sender;

@end