#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHFeedEntry;

@interface GHFeed : GHResource {
  @private
	NSURL *url;
	NSMutableArray *entries;
	NSMutableString *currentElementValue;
	NSDateFormatter *dateFormatter;
	GHFeedEntry *currentEntry;
}

@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSMutableArray *entries;

- (id)initWithURL:(NSURL *)theURL;
- (void)loadFeed;

@end
