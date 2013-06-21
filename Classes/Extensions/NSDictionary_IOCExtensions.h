#import <Foundation/Foundation.h>


@interface NSDictionary (IOCExtensions)
- (id)ioc_valueForKey:(NSString *)key defaultsTo:(id)defaultValue;
- (id)ioc_valueForKeyPath:(NSString *)keyPath defaultsTo:(id)defaultValue;
- (BOOL)ioc_boolForKey:(NSString *)key;
- (BOOL)ioc_boolForKeyPath:(NSString *)keyPath;
- (NSInteger)ioc_integerForKey:(NSString *)key;
- (NSDictionary *)ioc_dictForKey:(NSString *)key;
- (NSDictionary *)ioc_dictForKeyPath:(NSString *)keyPath;
- (NSString *)ioc_stringForKey:(NSString *)key;
- (NSString *)ioc_stringForKeyPath:(NSString *)keyPath;
- (NSString *)ioc_stringOrNilForKey:(NSString *)key;
- (NSString *)ioc_stringOrNilForKeyPath:(NSString *)keyPath;
- (NSArray *)ioc_arrayForKey:(NSString *)key;
- (NSArray *)ioc_arrayForKeyPath:(NSString *)keyPath;
- (NSDate *)ioc_dateForKey:(NSString *)key;
- (NSDate *)ioc_dateForKeyPath:(NSString *)keyPath;
- (NSURL *)ioc_URLForKey:(NSString *)key;
- (NSURL *)ioc_URLForKeyPath:(NSString *)keyPath;
@end