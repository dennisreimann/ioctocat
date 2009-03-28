#import <UIKit/UIKit.h>


@interface WebViewController : UIViewController <UIWebViewDelegate> {
  @private
	NSURL *url;
	IBOutlet UIWebView *webView;
	IBOutlet UIActivityIndicatorView *activityView;
}

@end
