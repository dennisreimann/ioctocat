#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHUser;

@interface GHOrganizations : GHResource

@property(nonatomic,strong)GHUser *user;
@property(nonatomic,strong)NSMutableArray *organizations;

- (id)initWithUser:(GHUser *)theUser andPath:(NSString *)thePath;

@end