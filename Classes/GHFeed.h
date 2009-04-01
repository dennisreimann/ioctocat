#import <Foundation/Foundation.h>


@class GHFeedEntry;

@interface GHFeed : NSObject {
	BOOL isLoaded;
	BOOL isLoading;
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
@property (nonatomic, readwrite) BOOL isLoading;

- (id)initWithURL:(NSURL *)theURL;
- (void)loadFeed;

@end
