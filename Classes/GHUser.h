#import <UIKit/UIKit.h>
#import "GHResource.h"


@class GravatarLoader;

@interface GHUser : GHResource {
	NSString *name;
	NSString *login;
	NSString *email;
	NSString *company;
	NSString *location;
	NSURL *blogURL;
	UIImage *gravatar;
	NSArray *repositories;
  @private
	GravatarLoader *gravatarLoader;
	GHResourceStatus repositoriesStatus;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *login;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *company;
@property (nonatomic, retain) NSString *location;
@property (nonatomic, retain) NSURL *blogURL;
@property (nonatomic, retain) UIImage *gravatar;
@property (nonatomic, retain) NSArray *repositories;
@property (nonatomic, readonly) NSString *cachedGravatarPath;
@property (nonatomic, readonly) BOOL isReposLoaded;
@property (nonatomic, readonly) BOOL isReposLoading;
@property (nonatomic, readwrite) GHResourceStatus repositoriesStatus;

- (id)initWithLogin:(NSString *)theLogin;
- (void)loadUser;
- (void)loadRepositories;
- (void)loadedUsers:(NSArray *)theUsers;
- (void)setLoadedRepositories:(NSArray *)theRepositories;
- (void)setLoadedGravatar:(UIImage *)theImage;

@end
