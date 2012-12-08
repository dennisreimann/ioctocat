#import <UIKit/UIKit.h>


@interface WebController : UIViewController <UIWebViewDelegate>
@property(nonatomic,weak)IBOutlet UIWebView *webView;
@property(nonatomic,strong)IBOutlet UIActivityIndicatorView *activityView;

- (id)initWithURL:(NSURL *)theURL;
- (id)initWithHTML:(NSString *)theHTML;
@end