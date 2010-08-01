#import <Foundation/Foundation.h>
#import "GHResource.h"
#import "GHFeedEntry.h"


@interface GHFeed : GHResource {
	NSDate *lastReadingDate;
  @private
	NSArray *entries;
}

@property(nonatomic,retain)NSArray *entries;
@property(nonatomic,retain)NSDate *lastReadingDate;

@end
