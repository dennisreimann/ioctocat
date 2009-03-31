#import <Foundation/Foundation.h>


@class GHFeedEntry;

@interface GHFeed : NSObject {
	NSURL *url;
	NSMutableArray *entries;
	NSMutableString *currentElementValue;
	NSDateFormatter *dateFormatter;
	GHFeedEntry *currentEntry;
	BOOL isLoaded;
}

@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSMutableArray *entries;
@property (nonatomic, readwrite) BOOL isLoaded;

- (id)initWithURL:(NSURL *)theURL;

@end
