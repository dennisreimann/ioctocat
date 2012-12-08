#import <UIKit/UIKit.h>


@interface CodeController : UIViewController <UIWebViewDelegate>
@property(nonatomic,weak)IBOutlet UIView *activityView;
@property(nonatomic,weak)IBOutlet UIWebView *contentView;
@property(nonatomic,weak)IBOutlet UISegmentedControl *navigationControl;
@property(nonatomic,strong)IBOutlet UIBarButtonItem *controlItem;

- (id)initWithFiles:(NSArray *)theFiles currentIndex:(NSUInteger)theCurrentIndex;
- (IBAction)segmentChanged:(UISegmentedControl *)segmentedControl;
@end