#import <Foundation/Foundation.h>
#import "GHResourcesParserDelegate.h"


@class GHFeedEntry;

@interface GHFeedParserDelegate : GHResourcesParserDelegate {
  @private
	NSDateFormatter *dateFormatter;
	GHFeedEntry *currentEntry;
}

@end
