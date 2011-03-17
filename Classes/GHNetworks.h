#import <Foundation/Foundation.h>
#import "GHResource.h"
#import "GHRepository.h"


@interface GHNetworks : GHResource <GHResourceImplementation> {
	NSArray *entries;
  @private
    GHRepository *repository;
}

@property(nonatomic,retain)GHRepository *repository;
@property(nonatomic,retain)NSArray *entries;

+ (id)networksWithRepository:(GHRepository *)theRepository;
- (id)initWithRepository:(GHRepository *)theRepository;

@end

