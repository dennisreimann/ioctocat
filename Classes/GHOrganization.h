#import <UIKit/UIKit.h>
#import "GHResource.h"


@class GravatarLoader, GHUsers, GHRepositories, GHRepository, GHFeed;

@interface GHOrganization : GHResource {
	NSString *name;
	NSString *login;
	NSString *email;
	NSString *company;
	NSString *location;
	NSURL *blogURL;
	NSURL *gravatarURL;
	UIImage *gravatar;
    NSUInteger followersCount;
    NSUInteger followingCount;
	NSUInteger publicGistCount;
	NSUInteger privateGistCount;
	NSUInteger publicRepoCount;
	NSUInteger privateRepoCount;
    GHUsers *publicMembers;
	GHRepositories *publicRepositories;
	GHFeed *recentActivity;
  @private
	GravatarLoader *gravatarLoader;
}

@property(nonatomic,retain)NSString *name;
@property(nonatomic,retain)NSString *login;
@property(nonatomic,retain)NSString *email;
@property(nonatomic,retain)NSString *company;
@property(nonatomic,retain)NSString *location;
@property(nonatomic,retain)NSURL *gravatarURL;
@property(nonatomic,retain)NSURL *blogURL;
@property(nonatomic,retain)UIImage *gravatar;
@property(nonatomic,retain)GHUsers *publicMembers;
@property(nonatomic,retain)GHRepositories *publicRepositories;
@property(nonatomic,retain)GHFeed *recentActivity;
@property(nonatomic)NSUInteger followersCount;
@property(nonatomic)NSUInteger followingCount;
@property(nonatomic)NSUInteger publicGistCount;
@property(nonatomic)NSUInteger privateGistCount;
@property(nonatomic)NSUInteger publicRepoCount;
@property(nonatomic)NSUInteger privateRepoCount;

+ (id)organizationWithLogin:(NSString *)theLogin;
- (id)initWithLogin:(NSString *)theLogin;
- (void)setLogin:(NSString *)theLogin;
- (void)loadedGravatar:(UIImage *)theImage;
- (void)setValuesFromDict:(NSDictionary *)theDict;

@end
