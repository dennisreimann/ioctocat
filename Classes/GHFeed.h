#import <Foundation/Foundation.h>
#import "GHResource.h"
#import "GHFeedEntry.h"


@interface GHFeed : GHResource {
  @private
	NSURL *url;
	NSArray *entries;
}

@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSArray *entries;

- (id)initWithURL:(NSURL *)theURL;
- (void)loadEntries;
- (void)loadedEntries:(id)theResult;

@end
