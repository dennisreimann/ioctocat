#import "GHResource.h"


@class GHUsers, GHOrganizations, GHNotifications, GHRepositories, GHRepository, GHEvents, GHGists, GHGist;

@interface GHUser : GHResource
@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *login;
@property(nonatomic,strong)NSString *email;
@property(nonatomic,strong)NSString *company;
@property(nonatomic,strong)NSString *location;
@property(nonatomic,strong)NSURL *gravatarURL;
@property(nonatomic,strong)NSURL *blogURL;
@property(nonatomic,strong)NSURL *htmlURL;
@property(nonatomic,strong)UIImage *gravatar;
@property(nonatomic,strong)GHNotifications *notifications;
@property(nonatomic,strong)GHOrganizations *organizations;
@property(nonatomic,strong)GHRepositories *repositories;
@property(nonatomic,strong)GHRepositories *starredRepositories;
@property(nonatomic,strong)GHRepositories *watchedRepositories;
@property(nonatomic,strong)GHEvents *events;
@property(nonatomic,strong)GHUsers *following;
@property(nonatomic,strong)GHUsers *followers;
@property(nonatomic,strong)GHGists *gists;
@property(nonatomic,strong)GHGists *starredGists;
@property(nonatomic,assign)BOOL isAuthenticated;
@property(nonatomic,assign)NSUInteger publicGistCount;
@property(nonatomic,assign)NSUInteger privateGistCount;
@property(nonatomic,assign)NSUInteger publicRepoCount;
@property(nonatomic,assign)NSUInteger privateRepoCount;
@property(nonatomic,assign)NSUInteger followersCount;
@property(nonatomic,assign)NSUInteger followingCount;

- (id)initWithLogin:(NSString *)login;
- (void)setLogin:(NSString *)login;
- (void)loadedGravatar:(UIImage *)image;
- (void)setFollowing:(BOOL)follow forUser:(GHUser *)user success:(resourceSuccess)success failure:(resourceFailure)failure;
- (void)setWatching:(BOOL)watch forRepository:(GHRepository *)repo success:(resourceSuccess)success failure:(resourceFailure)failure;
- (void)setStarring:(BOOL)starred forRepository:(GHRepository *)repo success:(resourceSuccess)success failure:(resourceFailure)failure;
- (void)setStarring:(BOOL)starred forGist:(GHGist *)gist success:(resourceSuccess)success failure:(resourceFailure)failure;
- (void)checkUserFollowing:(GHUser *)user success:(resourceSuccess)success failure:(resourceFailure)failure;
- (void)checkRepositoryStarring:(GHRepository *)repo success:(resourceSuccess)success failure:(resourceFailure)failure;
- (void)checkRepositoryWatching:(GHRepository *)repo success:(resourceSuccess)success failure:(resourceFailure)failure;
- (void)checkGistStarring:(GHGist *)gist success:(resourceSuccess)success failure:(resourceFailure)failure;
@end