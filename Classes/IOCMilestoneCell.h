@class GHMilestone;

@interface IOCMilestoneCell : UITableViewCell
@property(nonatomic,strong)GHMilestone *milestone;

+ (id)cellWithReuseIdentifier:(NSString *)reuseIdentifier;
- (CGFloat)heightForTableView:(UITableView *)tableView;
@end
