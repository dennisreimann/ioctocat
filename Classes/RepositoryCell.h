#import <UIKit/UIKit.h>
#import "GHRepository.h"


@interface RepositoryCell : UITableViewCell

@property(nonatomic,retain)GHRepository *repository;

+ (id)cell;
+ (id)cellWithIdentifier:(NSString *)reuseIdentifier;
- (void)hideOwner;

@end
