#import <UIKit/UIKit.h>


@interface CodeController : UIViewController <UIWebViewDelegate>

@property(nonatomic,strong)IBOutlet UIView *activityView;
@property(nonatomic,strong)IBOutlet UIWebView *contentView;
@property(nonatomic,strong)IBOutlet UIBarButtonItem *controlItem;
@property(nonatomic,strong)IBOutlet UISegmentedControl *navigationControl;

+ (id)controllerWithFiles:(NSArray *)theFiles currentIndex:(NSUInteger)theCurrentIndex;
- (id)initWithFiles:(NSArray *)theFiles currentIndex:(NSUInteger)theCurrentIndex;
- (IBAction)segmentChanged:(UISegmentedControl *)segmentedControl;

@end