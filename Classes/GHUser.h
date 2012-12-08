#import <UIKit/UIKit.h>
#import "GHResource.h"


@class GravatarLoader, GHUsers, GHOrganizations, GHRepositories, GHRepository, GHEvents, GHGists, GHGist;

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
@property(nonatomic,strong)GravatarLoader *gravatarLoader;
@property(nonatomic,strong)GHOrganizations *organizations;
@property(nonatomic,strong)GHRepositories *repositories;
@property(nonatomic,strong)GHRepositories *starredRepositories;
@property(nonatomic,strong)GHRepositories *watchedRepositories;
@property(nonatomic,strong)GHEvents *events;
@property(nonatomic,strong)GHUsers *following;
@property(nonatomic,strong)GHUsers *followers;
@property(nonatomic,strong)GHGists *gists;
@property(nonatomic,strong)GHGists *starredGists;
@property(nonatomic)BOOL isAuthenticated;
@property(nonatomic)NSUInteger publicGistCount;
@property(nonatomic)NSUInteger privateGistCount;
@property(nonatomic)NSUInteger publicRepoCount;
@property(nonatomic)NSUInteger privateRepoCount;
@property(nonatomic)NSUInteger followersCount;
@property(nonatomic)NSUInteger followingCount;

- (id)initWithLogin:(NSString *)theLogin;
- (void)setLogin:(NSString *)theLogin;
- (void)loadedGravatar:(UIImage *)theImage;
- (BOOL)isFollowing:(GHUser *)anUser;
- (BOOL)isStarring:(GHRepository *)aRepository;
- (BOOL)isWatching:(GHRepository *)aRepository;
- (void)followUser:(GHUser *)theUser;
- (void)unfollowUser:(GHUser *)theUser;
- (void)starRepository:(GHRepository *)theRepository;
- (void)unstarRepository:(GHRepository *)theRepository;
- (void)watchRepository:(GHRepository *)theRepository;
- (void)unwatchRepository:(GHRepository *)theRepository;
- (BOOL)isStarringGist:(GHGist *)theGist;
- (void)starGist:(GHGist *)theGist;
- (void)unstarGist:(GHGist *)theGist;

@end