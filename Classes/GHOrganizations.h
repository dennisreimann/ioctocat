#import <Foundation/Foundation.h>
#import "GHCollection.h"


@class GHUser;

@interface GHOrganizations : GHCollection
@property(nonatomic,strong)GHUser *user;

- (id)initWithUser:(GHUser *)theUser andPath:(NSString *)thePath;
@end