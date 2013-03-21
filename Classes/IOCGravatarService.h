@interface IOCGravatarService : NSObject
+ (void)loadWithURL:(NSURL *)url success:(void (^)(UIImage *))success failure:(void (^)())failure;
@end