@interface IOCAvatarLoader : NSObject
@property(nonatomic,readonly)NSInteger gravatarSize;

+ (id)loaderWithTarget:(id)theTarget andHandle:(SEL)theHandle;
- (id)initWithTarget:(id)theTarget andHandle:(SEL)theHandle;
- (void)loadURL:(NSURL *)theURL;
@end