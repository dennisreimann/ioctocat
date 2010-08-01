#import <Foundation/Foundation.h>


@interface GHResourcesParserDelegate : NSObject <NSXMLParserDelegate> {
	NSMutableArray *resources;
	NSMutableString *currentElementValue;
  @private
	id target;
	SEL selector;
	NSError *error;
}

- (id)initWithTarget:(id)theTarget andSelector:(SEL)theSelector;

@end
