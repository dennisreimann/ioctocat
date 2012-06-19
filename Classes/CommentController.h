#import <UIKit/UIKit.h>

@class GHComment;

@interface CommentController : UIViewController <UITextFieldDelegate> {
  @private
	GHComment *comment;
	id comments;
	IBOutlet UITextView *bodyView;
	IBOutlet UIBarButtonItem *postButton;
	IBOutlet UIActivityIndicatorView *activityView;
}

@property(nonatomic, retain)GHComment *comment;
@property(nonatomic, retain)id comments;

- (id)initWithComment:(GHComment *)theComment andComments:(id)theComments;
- (IBAction)postComment:(id)sender;

@end