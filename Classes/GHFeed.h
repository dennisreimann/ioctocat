#import <Foundation/Foundation.h>


@class GHFeedEntry;

@interface GHFeed : NSObject {
	BOOL isLoaded;
  @private
	NSURL *url;
	NSMutableArray *entries;
	NSMutableString *currentElementValue;
	NSDateFormatter *dateFormatter;
	GHFeedEntry *currentEntry;
}

@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSMutableArray *entries;
@property (nonatomic, readwrite) BOOL isLoaded;

- (id)initWithURL:(NSURL *)theURL;
- (void)loadFeed;
- (void)unloadFeed;

@end
