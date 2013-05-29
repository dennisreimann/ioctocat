#import "GHCollection.h"


@class GHUser;

@interface GHOrganizations : GHCollection
@property(nonatomic,strong)GHUser *user;

- (id)initWithUser:(GHUser *)user andPath:(NSString *)path;
@end