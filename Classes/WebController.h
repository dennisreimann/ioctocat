#import <UIKit/UIKit.h>


@interface WebController : UIViewController <UIWebViewDelegate> {
	IBOutlet UIWebView *webView;
	IBOutlet UIActivityIndicatorView *activityView;
  @private
	NSURL *url;
}

- (id)initWithURL:(NSURL *)theURL;

@end
