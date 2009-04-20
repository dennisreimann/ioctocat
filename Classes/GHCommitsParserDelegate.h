#import <Foundation/Foundation.h>


@class GHCommit;

@interface GHCommitsParserDelegate : NSObject {
  @private
	id target;
	SEL selector;
	NSMutableArray *commits;
	NSMutableString *currentElementValue;
	GHCommit *currentCommit;
}

- (id)initWithTarget:(id)theTarget andSelector:(SEL)theSelector;

@end
