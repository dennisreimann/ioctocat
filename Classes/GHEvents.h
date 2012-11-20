#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHRepository;

@interface GHEvents : GHResource {
	NSDate *lastReadingDate;
	NSArray *events;
}

@property(nonatomic,retain)NSArray *events;
@property(nonatomic,retain)NSDate *lastReadingDate;

+ (id)eventsWithRepository:(GHRepository *)theRepository;

@end