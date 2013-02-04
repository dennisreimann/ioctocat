@protocol IOCAccountFormControllerDelegate <NSObject>
- (void)updateAccount:(NSMutableDictionary *)account atIndex:(NSUInteger)idx;
@end


@interface IOCAccountFormController : UIViewController
@property(nonatomic,weak)id<IOCAccountFormControllerDelegate> delegate;

- (id)initWithAccount:(NSMutableDictionary *)accounts andIndex:(NSUInteger)idx;
@end