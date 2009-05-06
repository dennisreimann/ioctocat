#import <UIKit/UIKit.h>


@interface OverlayViewController : UIViewController {
  @private
	id target;
	SEL selector;
}
  
- (id)initWithTarget:(id)theTarget andSelector:(SEL)theSelector;

@end
