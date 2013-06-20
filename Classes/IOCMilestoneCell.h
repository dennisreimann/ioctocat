#import "IOCResourceEditingDelegate.h"


@class GHMilestone;

@interface IOCMilestoneCell : UITableViewCell
@property(nonatomic,strong)GHMilestone *milestone;
@property(nonatomic,weak)id<IOCResourceEditingDelegate> delegate;

+ (id)cellWithReuseIdentifier:(NSString *)reuseIdentifier;
- (CGFloat)heightForTableView:(UITableView *)tableView;
@end
