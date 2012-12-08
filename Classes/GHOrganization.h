#import <UIKit/UIKit.h>
#import "GHResource.h"


@class GravatarLoader, GHUsers, GHRepositories, GHRepository, GHEvents;

@interface GHOrganization : GHResource

@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *login;
@property(nonatomic,strong)NSString *email;
@property(nonatomic,strong)NSString *company;
@property(nonatomic,strong)NSString *location;
@property(nonatomic,strong)NSURL *gravatarURL;
@property(nonatomic,strong)NSURL *blogURL;
@property(nonatomic,strong)NSURL *htmlURL;
@property(nonatomic,strong)UIImage *gravatar;
@property(nonatomic,strong)GHUsers *publicMembers;
@property(nonatomic,strong)GHEvents *events;
@property(nonatomic,strong)GHRepositories *repositories;
@property(nonatomic,strong)GravatarLoader *gravatarLoader;
@property(nonatomic)NSUInteger followersCount;
@property(nonatomic)NSUInteger followingCount;
@property(nonatomic)NSUInteger publicGistCount;
@property(nonatomic)NSUInteger privateGistCount;
@property(nonatomic)NSUInteger publicRepoCount;
@property(nonatomic)NSUInteger privateRepoCount;

- (id)initWithLogin:(NSString *)theLogin;
- (void)setLogin:(NSString *)theLogin;
- (void)loadedGravatar:(UIImage *)theImage;

@end