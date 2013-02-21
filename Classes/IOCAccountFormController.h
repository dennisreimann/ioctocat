@class GHAccount;


@protocol IOCAccountFormControllerDelegate <NSObject>
- (void)updateAccount:(GHAccount *)account atIndex:(NSUInteger)idx;
@end


@interface IOCAccountFormController : UIViewController
@property(nonatomic,weak)id<IOCAccountFormControllerDelegate> delegate;

- (id)initWithAccount:(GHAccount *)account andIndex:(NSUInteger)idx;
@end