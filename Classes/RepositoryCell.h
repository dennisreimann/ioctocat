#import "GHRepository.h"


@interface RepositoryCell : UITableViewCell
@property(nonatomic,strong)GHRepository *repository;

+ (id)cellWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)hideOwner;
@end
