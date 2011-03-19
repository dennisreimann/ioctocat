#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHUser;

@interface GHUsers : GHResource {
	NSMutableArray *users;
  @private
    GHUser *user;
}

@property(nonatomic,retain)GHUser *user;
@property(nonatomic,retain)NSMutableArray *users;

+ (id)usersWithUser:(GHUser *)theUser andURL:(NSURL *)theURL;
- (id)initWithUser:(GHUser *)theUser andURL:(NSURL *)theURL;

@end
