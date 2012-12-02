#import <UIKit/UIKit.h>


@interface WebController : UIViewController <UIWebViewDelegate>
@property(nonatomic,weak)IBOutlet UIWebView *webView;
@property(nonatomic,strong)IBOutlet UIActivityIndicatorView *activityView;

+ (id)controllerWithURL:(NSURL *)theURL;
+ (id)controllerWithHTML:(NSString *)theHTML;
- (id)initWithURL:(NSURL *)theURL;
- (id)initWithHTML:(NSString *)theHTML;
@end