#import <UIKit/UIKit.h>


@interface WebController : UIViewController <UIWebViewDelegate> {
  @private
	NSURL *url;
	IBOutlet UIWebView *webView;
	IBOutlet UIActivityIndicatorView *activityView;
}

- (id)initWithURL:(NSURL *)theURL;

@end
