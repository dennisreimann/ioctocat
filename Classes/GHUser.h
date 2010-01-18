#import <UIKit/UIKit.h>
#import "GHResource.h"
#import "GHUsers.h"
#import "GHRepositories.h"


@class GravatarLoader, GHRepository, GHFeed;

@interface GHUser : GHResource {
	NSString *name;
	NSString *login;
	NSString *email;
	NSString *company;
	NSString *location;
	NSString *gravatarHash;
	NSURL *blogURL;
	UIImage *gravatar;
	NSUInteger publicGistCount;
	NSUInteger privateGistCount;
	NSUInteger publicRepoCount;
	NSUInteger privateRepoCount;
	GHRepositories *repositories;
	GHRepositories *watchedRepositories;
	GHFeed *recentActivity;
    GHUsers *following;
    GHUsers *followers;
	BOOL isAuthenticated;
  @private
	GravatarLoader *gravatarLoader;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *login;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *company;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSString *gravatarHash;
@property (nonatomic, retain) NSURL *blogURL;
@property (nonatomic, retain) UIImage *gravatar;
@property (nonatomic, retain) GHRepositories *repositories;
@property (nonatomic, retain) GHRepositories *watchedRepositories;
@property (nonatomic, retain) GHFeed *recentActivity;
@property (nonatomic, retain) GHUsers *following;
@property (nonatomic, retain) GHUsers *followers;
@property (nonatomic, readonly) NSString *cachedGravatarPath;
@property (nonatomic) BOOL isAuthenticated;
@property (nonatomic) NSUInteger publicGistCount;
@property (nonatomic) NSUInteger privateGistCount;
@property (nonatomic) NSUInteger publicRepoCount;
@property (nonatomic) NSUInteger privateRepoCount;

- (id)initWithLogin:(NSString *)theLogin;
- (void)setLogin:(NSString *)theLogin;
- (void)loadUser;
- (void)loadedUsers:(id)theResult;
- (void)loadedGravatar:(UIImage *)theImage;
- (void)authenticateWithToken:(NSString *)theToken;
- (BOOL)isFollowing:(GHUser *)anUser;
- (BOOL)isWatching:(GHRepository *)aRepository;
- (void)followUser:(GHUser *)theUser;
- (void)unfollowUser:(GHUser *)theUser;
- (void)watchRepository:(GHRepository *)theRepository;
- (void)unwatchRepository:(GHRepository *)theRepository;

@end
