#import <UIKit/UIKit.h>


@class GHBlob;

@interface BlobsController : UIViewController <UIWebViewDelegate> {
	GHBlob *blob;
	NSArray *blobs;
	NSUInteger index;
	IBOutlet UIView *activityView;
	IBOutlet UIWebView *contentView;
	IBOutlet UIBarButtonItem *controlItem;
	IBOutlet UISegmentedControl *navigationControl;
}

+ (id)controllerWithBlobs:(NSArray *)theBlobs currentIndex:(NSUInteger)theCurrentIndex;
- (id)initWithBlobs:(NSArray *)theBlobs currentIndex:(NSUInteger)theCurrentIndex;
- (IBAction)segmentChanged:(UISegmentedControl *)segmentedControl;

@end
