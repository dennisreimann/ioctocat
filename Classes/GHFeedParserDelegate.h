#import <Foundation/Foundation.h>
#import "GHResourcesParserDelegate.h"


@class GHFeedEntry;

@interface GHFeedParserDelegate : GHResourcesParserDelegate {
  @private
	GHFeedEntry *currentEntry;
}

@end
