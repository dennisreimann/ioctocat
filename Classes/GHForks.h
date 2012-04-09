#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHRepository;

@interface GHForks : GHResource {
	NSArray *entries;
  @private
    GHRepository *repository;
}

@property(nonatomic,retain)GHRepository *repository;
@property(nonatomic,retain)NSArray *entries;

+ (id)forksWithRepository:(GHRepository *)theRepository;
- (id)initWithRepository:(GHRepository *)theRepository;

@end

