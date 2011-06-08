#import <UIKit/UIKit.h>


@interface GravatarLoader : NSObject {
  @private
	id target;
	SEL handle;
}

- (id)initWithTarget:(id)theTarget andHandle:(SEL)theHandle;
- (void)loadEmail:(NSString *)theEmail;
- (void)loadHash:(NSString *)theHash;
- (void)loadURL:(NSURL *)theURL;

@property(nonatomic,readonly)NSInteger gravatarSize;

@end

