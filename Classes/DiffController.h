#import <UIKit/UIKit.h>


@interface DiffController : UIViewController <UIWebViewDelegate> {
	NSArray *files;
	NSUInteger index;
	IBOutlet UIWebView *contentView;
}

+ (id)controllerWithFiles:(NSArray *)theFiles currentIndex:(NSUInteger)theCurrentIndex;
- (id)initWithFiles:(NSArray *)theFiles currentIndex:(NSUInteger)theCurrentIndex;

@end
