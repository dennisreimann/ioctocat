#import <UIKit/UIKit.h>
#import "GHIssue.h"

@class GHIssueComment;

@interface IssueCommentController : UIViewController <UITextFieldDelegate> {
  @private
	GHIssueComment *comment;
	GHIssue *issue;
	IBOutlet UITextView *bodyView;
	IBOutlet UIBarButtonItem *postButton;
	IBOutlet UIActivityIndicatorView *activityView;
}

- (id)initWithIssue:(GHIssue *)theIssue;
- (IBAction)postComment:(id)sender;

@end