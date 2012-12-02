#import <UIKit/UIKit.h>


@class GHIssue;

@interface IssueCell : UITableViewCell

@property(nonatomic,strong)GHIssue *issue;
@property(nonatomic,weak)IBOutlet UILabel *dateLabel;
@property(nonatomic,weak)IBOutlet UILabel *titleLabel;
@property(nonatomic,weak)IBOutlet UILabel *detailLabel;
@property(nonatomic,weak)IBOutlet UILabel *votesLabel;
@property(nonatomic,weak)IBOutlet UILabel *repoLabel;
@property(nonatomic,weak)IBOutlet UILabel *issueNumber;
@property(nonatomic,weak)IBOutlet UIImageView *iconView;

- (void)hideRepo;

@end