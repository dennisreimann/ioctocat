@interface IOCResourceDrafts : NSObject
+ (NSDictionary *)draftForKey:(NSString *)key;
+ (void)saveDraft:(NSDictionary *)draft forKey:(NSString *)key;
+ (void)flush;
@end