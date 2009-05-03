#import <UIKit/UIKit.h>
#import "GHIssue.h"


@interface IssueController : UIViewController <UIWebViewDelegate,UIActionSheetDelegate> {
	GHIssue *issue;
  @private
	IBOutlet UILabel *dateLabel;
	IBOutlet UILabel *updatedLabel;    
	IBOutlet UILabel *voteLabel;    
	IBOutlet UILabel *titleLabel;
	IBOutlet UIImageView *iconView;
	IBOutlet UITextView *contentView;
}

@property (nonatomic, retain) GHIssue *issue;

- (id)initWithIssue:(GHIssue *)theIssue;
- (IBAction)showActions:(id)sender;


@end
