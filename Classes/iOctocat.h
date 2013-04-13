@class GHAccount, GHUser, GHOrganization;

@interface iOctocat : NSObject
@property(nonatomic,strong)GHAccount *currentAccount;
@property(nonatomic,strong)NSString *deviceToken;
@property(nonatomic,strong)IBOutlet UIWindow *window;
@property(nonatomic,readonly)NSMutableArray *accounts;

+ (instancetype)sharedInstance;
+ (void)reportWarning:(NSString *)title with:(NSString *)message;
+ (void)reportError:(NSString *)title with:(NSString *)message;
+ (void)reportLoadingError:(NSString *)message;
- (BOOL)openURL:(NSURL *)url;
- (void)bringStatusViewToFront;
- (void)registerForRemoteNotifications;
- (GHUser *)currentUser;
- (GHUser *)userWithLogin:(NSString *)login;
- (GHOrganization *)organizationWithLogin:(NSString *)login;
@end