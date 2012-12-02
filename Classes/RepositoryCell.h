#import <UIKit/UIKit.h>
#import "GHRepository.h"


@interface RepositoryCell : UITableViewCell
@property(nonatomic,strong)GHRepository *repository;

+ (id)cell;
+ (id)cellWithIdentifier:(NSString *)reuseIdentifier;
- (void)hideOwner;
@end
