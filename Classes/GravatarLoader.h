#import <UIKit/UIKit.h>


@interface GravatarLoader : NSObject

+ (id)loaderWithTarget:(id)theTarget andHandle:(SEL)theHandle;
- (id)initWithTarget:(id)theTarget andHandle:(SEL)theHandle;
- (void)loadURL:(NSURL *)theURL;

@property(nonatomic,readonly)NSInteger gravatarSize;

@end