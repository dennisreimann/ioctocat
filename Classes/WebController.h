#import <UIKit/UIKit.h>


@interface WebController : UIViewController <UIWebViewDelegate> {
	IBOutlet UIWebView *webView;
	IBOutlet UIActivityIndicatorView *activityView;
  @private
	NSURL *url;
	NSString *html;
}

+ (id)controllerWithURL:(NSURL *)theURL;
+ (id)controllerWithHTML:(NSString *)theHTML;
- (id)initWithURL:(NSURL *)theURL;
- (id)initWithHTML:(NSString *)theHTML;

@end
