#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHRepository;

@interface GHBranches : GHResource {
	NSMutableArray *branches;
	GHRepository *repository;
}

@property(nonatomic,retain)NSMutableArray *branches;
@property(nonatomic,retain)GHRepository *repository;

+ (id)branchesWithRepository:(GHRepository *)theRepository;
- (id)initWithRepository:(GHRepository *)theRepository;

@end