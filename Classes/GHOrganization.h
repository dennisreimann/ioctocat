#import "GHResource.h"


@class GHUsers, GHRepositories, GHEvents;

@interface GHOrganization : GHResource
@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *login;
@property(nonatomic,strong)NSString *email;
@property(nonatomic,strong)NSString *location;
@property(nonatomic,strong)NSURL *gravatarURL;
@property(nonatomic,strong)NSURL *blogURL;
@property(nonatomic,strong)NSURL *htmlURL;
@property(nonatomic,strong)UIImage *gravatar;
@property(nonatomic,strong)GHUsers *publicMembers;
@property(nonatomic,strong)GHEvents *events;
@property(nonatomic,strong)GHRepositories *repositories;
@property(nonatomic,assign)NSUInteger publicRepoCount;
@property(nonatomic,assign)NSUInteger privateRepoCount;

- (id)initWithLogin:(NSString *)login;
@end