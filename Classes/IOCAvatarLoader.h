@interface IOCAvatarLoader : NSObject
@property(nonatomic,readonly)NSInteger gravatarSize;

+ (id)loaderWithTarget:(id)target andHandle:(SEL)handle;
- (id)initWithTarget:(id)target andHandle:(SEL)handle;
- (void)loadURL:(NSURL *)url;
@end