#import "GHRepository.h"


@interface RepositoryCell : UITableViewCell
@property(nonatomic,strong)GHRepository *repository;

+ (id)cell;
- (void)hideOwner;
@end
