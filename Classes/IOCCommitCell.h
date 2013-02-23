#import "GHCommit.h"


@interface IOCCommitCell : UITableViewCell
@property(nonatomic,strong)GHCommit *commit;

+ (id)cell;
@end
