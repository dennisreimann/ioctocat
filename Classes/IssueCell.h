#import <UIKit/UIKit.h>


@class GHIssue;

@interface IssueCell : UITableViewCell

@property(nonatomic,strong)GHIssue *issue;
@property(nonatomic,strong)IBOutlet UILabel *dateLabel;
@property(nonatomic,strong)IBOutlet UILabel *titleLabel;
@property(nonatomic,strong)IBOutlet UILabel *detailLabel;
@property(nonatomic,strong)IBOutlet UILabel *votesLabel;
@property(nonatomic,strong)IBOutlet UILabel *repoLabel;
@property(nonatomic,strong)IBOutlet UILabel *issueNumber;
@property(nonatomic,strong)IBOutlet UIImageView *iconView;

- (void)hideRepo;

@end