#import <Foundation/Foundation.h>
#import "GHResource.h"


@interface GHRepositories : GHResource <GHResourceImplementation> {
	NSMutableArray *repositories;
}

@property(nonatomic,retain)NSMutableArray *repositories;

+ (id)repositoriesWithURL:(NSURL *)theURL;
- (id)initWithURL:(NSURL *)theURL;

@end
