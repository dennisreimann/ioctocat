@class GHAccount, GHUser, GHOrganization;

@interface iOctocat : NSObject
@property(nonatomic,strong)GHAccount *currentAccount;
@property(nonatomic,strong)IBOutlet UIWindow *window;

+ (iOctocat *)sharedInstance;
+ (void)reportError:(NSString *)title with:(NSString *)message;
+ (void)reportLoadingError:(NSString *)message;
+ (void)reportSuccess:(NSString *)message;
- (BOOL)openURL:(NSURL *)url;
- (GHUser *)currentUser;
- (GHUser *)userWithLogin:(NSString *)login;
- (GHOrganization *)organizationWithLogin:(NSString *)login;
@end