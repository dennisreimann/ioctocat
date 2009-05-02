#import <Foundation/Foundation.h>


@interface GHResourcesParserDelegate : NSObject {
	NSMutableArray *resources;
	NSMutableString *currentElementValue;
  @private
	id target;
	SEL selector;
	NSError *error;
}

- (id)initWithTarget:(id)theTarget andSelector:(SEL)theSelector;

@end
