#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHUser;

@interface GHRepositories : GHResource {
	NSArray *repositories;
  @private
    GHUser *user;
	NSURL *repositoriesURL;
}

@property (nonatomic, retain) GHUser *user;
@property (nonatomic, retain) NSArray *repositories;
@property (nonatomic, retain) NSURL *repositoriesURL;

- (id)initWithUser:(GHUser *)theUser andURL:(NSURL *)theURL;
- (void)loadRepositories;

@end
