#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHRepository, GHFeed;

@interface GHBranch : GHResource {
	GHRepository *repository;
	GHFeed *recentCommits;
    NSString *name;
    NSString *sha;
}

@property(nonatomic,retain)GHRepository *repository;
@property(nonatomic,retain)GHFeed *recentCommits;
@property(nonatomic,retain)NSString *name;
@property(nonatomic,retain)NSString *sha;

- (id)initWithRepository:(GHRepository *)theRepository andName:(NSString *)theName;

@end