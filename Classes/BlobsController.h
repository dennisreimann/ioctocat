#import <UIKit/UIKit.h>


@class GHBlob;

@interface BlobsController : UIViewController <UIWebViewDelegate>

@property(nonatomic,weak)IBOutlet UIView *activityView;
@property(nonatomic,weak)IBOutlet UIWebView *contentView;
@property(nonatomic,weak)IBOutlet UIBarButtonItem *controlItem;
@property(nonatomic,weak)IBOutlet UISegmentedControl *navigationControl;

+ (id)controllerWithBlobs:(NSArray *)theBlobs currentIndex:(NSUInteger)theCurrentIndex;
- (id)initWithBlobs:(NSArray *)theBlobs currentIndex:(NSUInteger)theCurrentIndex;
- (IBAction)segmentChanged:(UISegmentedControl *)segmentedControl;

@end