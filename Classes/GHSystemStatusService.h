@interface GHSystemStatusService : NSObject
+ (void)checkWithMajor:(void (^)(NSString *message))onMajor minor:(void (^)(NSString *message))onMinor good:(void (^)(NSString *message))onGood failure:(void (^)(NSError *error))onFailure;
@end