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
@property(nonatomic,strong)NSString *mergeableState;
@property(nonatomic,strong)NSArray *labels;
@property(nonatomic,strong)NSDate *createdAt;
@property(nonatomic,strong)NSDate *updatedAt;
@property(nonatomic,strong)NSDate *closedAt;
@property(nonatomic,strong)NSDate *mergedAt;
@property(nonatomic,strong)NSURL *htmlURL;
@property(nonatomic,assign)NSInteger number;
@property(nonatomic,readonly)NSString *repoIdWithIssueNumber;
@property(nonatomic,readonly)BOOL isNew;
@property(nonatomic,readonly)BOOL isOpen;
@property(nonatomic,readonly)BOOL isMerged;
@property(nonatomic,readonly)BOOL isMergeable;
@property(nonatomic,readonly)NSMutableAttributedString *attributedBody;

- (id)initWithRepository:(GHRepository *)repo;
- (void)mergePullRequest:(NSString *)commitMessage start:(resourceStart)start success:(resourceSuccess)success failure:(resourceFailure)failure;
@end