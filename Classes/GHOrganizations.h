#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHUser;

@interface GHOrganizations : GHResource

@property(nonatomic,retain)GHUser *user;
@property(nonatomic,retain)NSMutableArray *organizations;

+ (id)organizationsWithUser:(GHUser *)theUser andPath:(NSString *)thePath;
- (id)initWithUser:(GHUser *)theUser andPath:(NSString *)thePath;

@end