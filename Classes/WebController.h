#import <UIKit/UIKit.h>


@interface WebController : UIViewController <UIWebViewDelegate> {
	IBOutlet UIWebView *webView;
	IBOutlet UIActivityIndicatorView *activityView;
  @private
	NSURL *url;
	NSString *html;
}

- (id)initWithURL:(NSURL *)theURL;
- (id)initWithHTML:(NSString *)theHTML;

@end
