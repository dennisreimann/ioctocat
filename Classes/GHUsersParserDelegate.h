#import <Foundation/Foundation.h>


@class GHUser;

@interface GHUsersParserDelegate : NSObject {
  @private
	id target;
	SEL selector;
	NSMutableArray *users;
	NSMutableString *currentElementValue;
	GHUser *currentUser;
}

- (id)initWithTarget:(id)theTarget andSelector:(SEL)theSelector;

@end
