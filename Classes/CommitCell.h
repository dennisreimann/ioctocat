#import "GHCommit.h"


@interface CommitCell : UITableViewCell
@property(nonatomic,strong)GHCommit *commit;

+ (id)cell;
+ (id)cellWithIdentifier:(NSString *)reuseIdentifier;
@end
