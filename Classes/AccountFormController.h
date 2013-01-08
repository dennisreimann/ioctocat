@protocol AccountFormControllerDelegate <NSObject>
- (void)updateAccount:(NSMutableDictionary *)account atIndex:(NSUInteger)idx;
@end


@interface AccountFormController : UIViewController
@property(nonatomic,weak)id<AccountFormControllerDelegate> delegate;

- (id)initWithAccount:(NSMutableDictionary *)accounts andIndex:(NSUInteger)idx;
@end