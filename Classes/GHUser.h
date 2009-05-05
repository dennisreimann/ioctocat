#import <UIKit/UIKit.h>
#import "GHResource.h"


@class GravatarLoader, GHRepository;

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
	NSArray *repositories;
    NSArray *following;
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
@property (nonatomic, retain) NSArray *repositories;
@property (nonatomic, retain) NSArray *following;
@property (nonatomic, readonly) NSString *cachedGravatarPath;
@property (nonatomic, readonly) BOOL isReposLoaded;
@property (nonatomic, readonly) BOOL isFollowingLoaded;
@property (nonatomic, readonly) BOOL isReposLoading;
@property (nonatomic) BOOL isAuthenticated;
@property (nonatomic) GHResourceStatus repositoriesStatus;
@property (nonatomic) GHResourceStatus followingStatus;
@property (nonatomic) NSUInteger publicGistCount;
@property (nonatomic) NSUInteger privateGistCount;
@property (nonatomic) NSUInteger publicRepoCount;
@property (nonatomic) NSUInteger privateRepoCount;

- (id)initWithLogin:(NSString *)theLogin;
- (void)loadUser;
- (void)loadedUsers:(id)theResult;
- (void)loadRepositories;
- (void)loadFollowing;
- (void)loadedRepositories:(NSArray *)theRepositories;
- (void)loadedGravatar:(UIImage *)theImage;
- (void)authenticateWithToken:(NSString *)theToken;
- (BOOL)isFollowing:(GHUser *)anUser;
- (BOOL)isWatching:(GHRepository *)aRepository;

@end
