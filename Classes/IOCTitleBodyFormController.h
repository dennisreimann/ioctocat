#import "IOCResourceEditingDelegate.h"


@class GHResource;

@interface IOCTitleBodyFormController : UIViewController
@property(nonatomic,weak)id<IOCResourceEditingDelegate> delegate;
@property(nonatomic,strong)NSString *titleAttributeName;
@property(nonatomic,strong)NSString *bodyAttributeName;

- (id)initWithResource:(GHResource *)resource name:(NSString *)resourceName;
@end