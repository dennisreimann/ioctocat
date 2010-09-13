#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHUser;

@interface GHRepositories : GHResource {
	NSMutableArray *repositories;
  @private
    GHUser *user;
}

@property(nonatomic,retain)GHUser *user;
@property(nonatomic,retain)NSMutableArray *repositories;

+ (id)repositoriesWithUser:(GHUser *)theUser andURL:(NSURL *)theURL;
- (id)initWithUser:(GHUser *)theUser andURL:(NSURL *)theURL;

@end
