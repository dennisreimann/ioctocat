#import <Foundation/Foundation.h>


@class GHRepository;

@interface GHReposParserDelegate : NSObject {
  @private
	id target;
	SEL selector;
	NSError *error;
	NSMutableArray *repositories;
	NSMutableString *currentElementValue;
	GHRepository *currentRepository;
}

- (id)initWithTarget:(id)theTarget andSelector:(SEL)theSelector;

@end
