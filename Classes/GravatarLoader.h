#import <UIKit/UIKit.h>


@interface GravatarLoader : NSObject {
  @private
	id target;
	SEL handle;
}

- (id)initWithTarget:(id)theTarget andHandle:(SEL)theHandle;
- (void)loadEmail:(NSString *)theEmail withSize:(NSInteger)theSize;
- (void)loadHash:(NSString *)theHash withSize:(NSInteger)theSize;

@end

