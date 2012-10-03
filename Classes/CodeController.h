#import <UIKit/UIKit.h>


@interface CodeController : UIViewController <UIWebViewDelegate> {
	IBOutlet UIWebView *webView;
	IBOutlet UIActivityIndicatorView *activityView;
  @private
	NSString *code;
	NSString *language;
}

+ (id)controllerWithCode:(NSString *)theCode language:(NSString *)theLang;
- (id)initWithCode:(NSString *)theCode language:(NSString *)theLang;

@end
