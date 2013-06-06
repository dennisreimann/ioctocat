#import "GHRepository.h"


@interface IOCRepositoryCell : UITableViewCell
@property(nonatomic,strong)GHRepository *repository;

+ (id)cellWithReuseIdentifier:(NSString *)reuseIdentifier;
- (void)hideOwner;
@end
