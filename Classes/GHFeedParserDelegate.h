#import <Foundation/Foundation.h>


@class GHFeedEntry;

@interface GHFeedParserDelegate : NSObject {
  @private
	id target;
	SEL selector;
	NSMutableArray *entries;
	NSMutableString *currentElementValue;
	NSDateFormatter *dateFormatter;
	NSError *error;
	GHFeedEntry *currentEntry;
}

- (id)initWithTarget:(id)theTarget andSelector:(SEL)theSelector;

@end
