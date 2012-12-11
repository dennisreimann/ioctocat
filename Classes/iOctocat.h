@class GHAccount, GHUser, GHOrganization;

@interface iOctocat : NSObject
@property(nonatomic,strong)GHAccount *currentAccount;
@property(nonatomic,strong)IBOutlet UIWindow *window;

+ (iOctocat *)sharedInstance;
+ (NSDate *)parseDate:(NSString *)theString;
+ (void)reportError:(NSString *)theTitle with:(NSString *)theMessage;
+ (void)reportLoadingError:(NSString *)theMessage;
+ (void)reportSuccess:(NSString *)theMessage;
- (BOOL)openURL:(NSURL *)url;
- (GHUser *)currentUser;
- (GHUser *)userWithLogin:(NSString *)theLogin;
- (GHOrganization *)organizationWithLogin:(NSString *)theLogin;
@end