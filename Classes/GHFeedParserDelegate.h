#import <Foundation/Foundation.h>

@class GHFeedEntry;

@interface GHFeedParserDelegate : NSObject <NSXMLParserDelegate> {
    NSMutableArray *resources;
	NSMutableString *currentElementValue;
  @private
	id target;
	SEL selector;
	NSError *error;
	GHFeedEntry *currentEntry;
}

- (id)initWithTarget:(id)theTarget andSelector:(SEL)theSelector;

@end
