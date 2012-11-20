#import <UIKit/UIKit.h>


@interface CodeController : UIViewController <UIWebViewDelegate> {
	IBOutlet UIView *activityView;
	IBOutlet UIWebView *contentView;
	IBOutlet UIBarButtonItem *controlItem;
	IBOutlet UISegmentedControl *navigationControl;
	@private
	NSArray *files;
	NSUInteger index;
	NSDictionary *file;
}

+ (id)controllerWithFiles:(NSArray *)theFiles currentIndex:(NSUInteger)theCurrentIndex;
- (id)initWithFiles:(NSArray *)theFiles currentIndex:(NSUInteger)theCurrentIndex;
- (IBAction)segmentChanged:(UISegmentedControl *)segmentedControl;

@end