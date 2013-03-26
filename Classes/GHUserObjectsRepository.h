@class GHUser, GHOrganization;

@interface GHUserObjectsRepository : NSObject
- (GHUser *)userWithLogin:(NSString *)login;
- (GHOrganization *)organizationWithLogin:(NSString *)login;
@end