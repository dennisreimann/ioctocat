#import <UIKit/UIKit.h>
#import "GHIssue.h"


@interface IssueDetailController : UIViewController <UIActionSheetDelegate> {
	GHIssue *issue;
  @private
	IBOutlet UILabel *dateLabel;
	IBOutlet UILabel *voteLabel;    
	IBOutlet UILabel *titleLabel;
	IBOutlet UIImageView *iconView;
	IBOutlet UITextView *contentView;
}

@property (nonatomic, retain) GHIssue *issue;

- (id)initWithIssue:(GHIssue *)theIssue;

@end
