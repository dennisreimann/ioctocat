#import "IOCResourceEditingDelegate.h"


@class GHResource;

@interface IOCTitleBodyFormController : UIViewController
@property(nonatomic,weak)id<IOCResourceEditingDelegate> delegate;
@property(nonatomic,strong)NSString *resourceTitleAttributeName;
@property(nonatomic,strong)NSString *resourceBodyAttributeName;
@property(nonatomic,strong)NSString *apiTitleAttributeName;
@property(nonatomic,strong)NSString *apiBodyAttributeName;

- (id)initWithResource:(GHResource *)resource name:(NSString *)resourceName;
@end