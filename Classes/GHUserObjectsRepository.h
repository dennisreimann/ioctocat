@class GHUser, GHOrganization;

@interface GHUserObjectsRepository : NSObject
@property(nonatomic,readonly)NSMutableDictionary *users;
- (GHUser *)userWithLogin:(NSString *)login;
- (GHOrganization *)organizationWithLogin:(NSString *)login;
@end