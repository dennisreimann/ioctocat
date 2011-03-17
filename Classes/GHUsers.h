#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHUser;

@interface GHUsers : GHResource <GHResourceImplementation> {
	NSMutableArray *users;
  @private
    GHUser *user;
}

@property(nonatomic,retain)GHUser *user;
@property(nonatomic,retain)NSMutableArray *users;

- (id)initWithUser:(GHUser *)theUser andURL:(NSURL *)theURL;

@end
