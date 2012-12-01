#import <UIKit/UIKit.h>


@class GHBlob;

@interface BlobsController : UIViewController <UIWebViewDelegate>

@property(nonatomic,strong)IBOutlet UIView *activityView;
@property(nonatomic,strong)IBOutlet UIWebView *contentView;
@property(nonatomic,strong)IBOutlet UIBarButtonItem *controlItem;
@property(nonatomic,strong)IBOutlet UISegmentedControl *navigationControl;

+ (id)controllerWithBlobs:(NSArray *)theBlobs currentIndex:(NSUInteger)theCurrentIndex;
- (id)initWithBlobs:(NSArray *)theBlobs currentIndex:(NSUInteger)theCurrentIndex;
- (IBAction)segmentChanged:(UISegmentedControl *)segmentedControl;

@end