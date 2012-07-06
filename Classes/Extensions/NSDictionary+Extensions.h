#import <Foundation/Foundation.h>


@interface NSDictionary (Extensions)
- (id)valueForKey:(NSString *)key defaultsTo:(id)defaultValue;
- (id)valueForKeyPath:(NSString *)keyPath defaultsTo:(id)defaultValue;
@end
