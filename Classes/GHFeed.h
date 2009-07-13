#import <Foundation/Foundation.h>
#import "GHResource.h"
#import "GHFeedEntry.h"


@interface GHFeed : GHResource {
	NSDate *lastReadingDate;
  @private
	NSURL *url;
	NSArray *entries;
}

@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSArray *entries;
@property (nonatomic, retain) NSDate *lastReadingDate;

- (id)initWithURL:(NSURL *)theURL;
- (void)loadEntries;
- (void)loadedEntries:(id)theResult;

@end
