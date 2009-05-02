#import <Foundation/Foundation.h>


@class GHIssue;

@interface GHIssuesParserDelegate : NSObject {
@private
	id target;
	SEL selector;
    NSMutableArray *entries;
    GHIssue *currentIssue;
	NSError *error;
    NSDateFormatter *dateFormatter;

	NSMutableString *currentElementValue;
    


}

- (id)initWithTarget:(id)theTarget andSelector:(SEL)theSelector;

@end
