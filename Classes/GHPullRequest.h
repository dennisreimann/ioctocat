#import "GHResource.h"


@class GHIssueComments, GHRepository, GHUser, GHBranch, GHFiles, GHCommits;

@interface GHPullRequest : GHResource
@property(nonatomic,strong)GHUser *user;
@property(nonatomic,strong)GHRepository *repository;
@property(nonatomic,strong)GHIssueComments *comments;
@property(nonatomic,strong)GHCommits *commits;
@property(nonatomic,strong)GHFiles *files;
@property(nonatomic,strong)GHBranch *head;
@property(nonatomic,strong)NSString *title;
@property(nonatomic,strong)NSString *body;
@property(nonatomic,strong)NSString *state;
@property(nonatomic,strong)NSArray *labels;
@property(nonatomic,strong)NSDate *created;
@property(nonatomic,strong)NSDate *updated;
@property(nonatomic,strong)NSDate *closed;
@property(nonatomic,strong)NSDate *merged;
@property(nonatomic,strong)NSURL *htmlURL;
@property(nonatomic,assign)NSInteger num;
@property(nonatomic,readonly)BOOL isNew;
@property(nonatomic,readonly)BOOL isOpen;
@property(nonatomic,readonly)BOOL isMerged;
@property(nonatomic,readonly)BOOL isMergeable;
@property(nonatomic,readonly)BOOL isClosed;

- (id)initWithRepository:(GHRepository *)repo;
- (void)mergePullRequest:(NSString *)commitMessage start:(resourceStart)start success:(resourceSuccess)success failure:(resourceFailure)failure;
- (void)saveWithParams:(NSDictionary *)params start:(resourceStart)start success:(resourceSuccess)success failure:(resourceFailure)failure;
@end