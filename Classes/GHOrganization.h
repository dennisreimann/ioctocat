#import <UIKit/UIKit.h>
#import "GHResource.h"
#import "GHRepositories.h"
#import "GHUsers.h"


@class GravatarLoader, GHRepository, GHUser, GHFeed;

@interface GHOrganization : GHResource {
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
    GHUsers *publicMembers;
	GHRepositories *publicRepositories;
	GHFeed *recentActivity;
    GHUser *user;
  @private
	GravatarLoader *gravatarLoader;
}

@property(nonatomic,retain)NSString *name;
@property(nonatomic,retain)NSString *login;
@property(nonatomic,retain)NSString *email;
@property(nonatomic,retain)NSString *company;
@property(nonatomic,retain)NSString *location;
@property(nonatomic,retain)NSString *gravatarHash;
@property(nonatomic,retain)NSURL *blogURL;
@property(nonatomic,retain)UIImage *gravatar;
@property(nonatomic,retain)GHUsers *publicMembers;
@property(nonatomic,retain)GHRepositories *publicRepositories;
@property(nonatomic,retain)GHFeed *recentActivity;
@property(nonatomic,retain)GHUser *user;
@property(nonatomic)NSUInteger publicGistCount;
@property(nonatomic)NSUInteger privateGistCount;
@property(nonatomic)NSUInteger publicRepoCount;
@property(nonatomic)NSUInteger privateRepoCount;

+ (id)organization;
+ (id)organizationWithLogin:(NSString *)theLogin;
- (id)initWithLogin:(NSString *)theLogin;
- (void)setLogin:(NSString *)theLogin;
- (void)loadedGravatar:(UIImage *)theImage;

@end
