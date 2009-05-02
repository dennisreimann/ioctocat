#import <UIKit/UIKit.h>


@class GHIssue;

@interface OpenIssueCell : UITableViewCell {
	GHIssue *issue;
@private
	IBOutlet UILabel *dateLabel;
	IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *detailLabel;
    IBOutlet UILabel *votesLabel;    
	IBOutlet UIImageView *iconView;
}

@property (nonatomic, retain) GHIssue *issue;

@end
