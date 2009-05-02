#import <UIKit/UIKit.h>


@class GHIssue;

@interface IssueDetailController : UIViewController <UIActionSheetDelegate> {
	GHIssue *issue;
    NSString *repository;
  @private
	IBOutlet UILabel *dateLabel;
	IBOutlet UILabel *voteLabel;    
	IBOutlet UILabel *titleLabel;
	IBOutlet UIImageView *iconView;
	IBOutlet UITextView *contentView;
}

@property (nonatomic, retain) GHIssue *issue;
@property (nonatomic, retain) NSString *repository;

- (id)initWithIssue:(GHIssue *)theIssue andRepository:(NSString *)theRepo;

@end
