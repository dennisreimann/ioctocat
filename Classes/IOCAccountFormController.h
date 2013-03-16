@class GHAccount;


@protocol IOCAccountFormControllerDelegate <NSObject>
@optional
- (void)updateAccount:(GHAccount *)account atIndex:(NSUInteger)idx  callback:(void (^)(NSUInteger idx))callback;
- (void)removeAccountAtIndex:(NSUInteger)idx  callback:(void (^)(NSUInteger idx))callback;
- (NSUInteger)indexOfAccountWithLogin:(NSString *)login endpoint:(NSString *)endpoint;
@end


@interface IOCAccountFormController : UIViewController
@property(nonatomic,weak)id<IOCAccountFormControllerDelegate> delegate;

- (id)initWithAccount:(GHAccount *)account andIndex:(NSUInteger)idx;
@end