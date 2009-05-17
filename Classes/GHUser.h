#import <UIKit/UIKit.h>
#import "GHResource.h"
#import "GHUsers.h"


@class GravatarLoader, GHRepository, GHFeed;

@interface GHUser : GHResource {
	NSString *name;
	NSString *login;
	NSString *email;
	NSString *company;
	NSString *location;
	NSURL *blogURL;
	UIImage *gravatar;
	NSUInteger publicGistCount;
	NSUInteger privateGistCount;
	NSUInteger publicRepoCount;
	NSUInteger privateRepoCount;
	NSMutableArray *repositories;
	GHFeed *recentActivity;
    GHUsers *following;
    GHUsers *followers;
	BOOL isAuthenticated;
  @private
	GravatarLoader *gravatarLoader;
	GHResourceStatus repositoriesStatus;
    GHResourceStatus followingStatus;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *login;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *company;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSURL *blogURL;
@property (nonatomic, retain) UIImage *gravatar;
@property (nonatomic, retain) NSMutableArray *repositories;
@property (nonatomic, retain) GHFeed *recentActivity;
@property (nonatomic, retain) GHUsers *following;
@property (nonatomic, retain) GHUsers *followers;
@property (nonatomic, readonly) NSString *cachedGravatarPath;
@property (nonatomic, readonly) BOOL isReposLoaded;
@property (nonatomic, readonly) BOOL isReposLoading;
@property (nonatomic) BOOL isAuthenticated;
@property (nonatomic) GHResourceStatus repositoriesStatus;
@property (nonatomic) NSUInteger publicGistCount;
@property (nonatomic) NSUInteger privateGistCount;
@property (nonatomic) NSUInteger publicRepoCount;
@property (nonatomic) NSUInteger privateRepoCount;

- (id)initWithLogin:(NSString *)theLogin;
- (void)loadUser;
- (void)loadedUsers:(id)theResult;
- (void)loadRepositories;
- (void)loadedRepositories:(NSArray *)theRepositories;
- (void)loadedGravatar:(UIImage *)theImage;
- (void)authenticateWithToken:(NSString *)theToken;
- (BOOL)isFollowing:(GHUser *)anUser;
- (BOOL)isWatching:(GHRepository *)aRepository;
- (void)setFollowingState:(NSString *)theState forUser:(GHUser *)theUser;
- (void)setWatchingState:(NSString *)theState forRepository:(GHRepository *)theRepository;

@end
