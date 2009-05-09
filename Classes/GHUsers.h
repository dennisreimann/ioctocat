#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHUser;

@interface GHUsers : GHResource {
	NSArray *users;
  @private
    GHUser *user;
	NSURL *usersURL;
}

@property (nonatomic, retain) GHUser *user;
@property (nonatomic, retain) NSArray *users;
@property (nonatomic, retain) NSURL *usersURL;

- (void)loadUsers;
- (void)loadedUsers:(id)theResult;
- (id)initWithUser:(GHUser *)theUser andURL:(NSURL *)theURL;

@end
