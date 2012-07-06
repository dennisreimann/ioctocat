#import <Foundation/Foundation.h>


@interface NSDictionary (Extensions)
- (id)valueForKey:(NSString *)key defaultsTo:(id)defaultValue;
@end
