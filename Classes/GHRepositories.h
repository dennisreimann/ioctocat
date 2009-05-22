#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHUser;

@interface GHRepositories : GHResource <NSCoding> {
	NSMutableArray *repositories;
  @private
    GHUser *user;
	NSURL *repositoriesURL;
}

@property (nonatomic, retain) GHUser *user;
@property (nonatomic, retain) NSMutableArray *repositories;
@property (nonatomic, retain) NSURL *repositoriesURL;

- (id)initWithUser:(GHUser *)theUser andURL:(NSURL *)theURL;
- (void)loadRepositories;

@end
