#import <UIKit/UIKit.h>


@interface DiffController : UIViewController <UIWebViewDelegate> {
	NSArray *files;
	NSUInteger index;
	IBOutlet UIWebView *contentView;
}

- (id)initWithFiles:(NSArray *)theFiles currentIndex:(NSUInteger)theCurrentIndex;

@end
