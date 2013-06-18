#import "GHResource.h"


@class GHIssues, GHPullRequests, GHForks, GHTags, GHBranches, GHMilestones, GHLabels, GHUser, GHReadme, GHEvents, GHUsers;

@interface GHRepository : GHResource
@property(nonatomic,readonly)NSString *repoId;
@property(nonatomic,readonly)NSMutableAttributedString *attributedDescriptionText;
@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *owner;
@property(nonatomic,strong)NSString *descriptionText;
@property(nonatomic,strong)NSString *mainBranch;
@property(nonatomic,strong)NSString *language;
@property(nonatomic,strong)NSURL *htmlURL;
@property(nonatomic,strong)NSURL *homepageURL;
@property(nonatomic,strong)NSDate *pushedAtDate;
@property(nonatomic,strong)GHIssues *openIssues;
@property(nonatomic,strong)GHIssues *closedIssues;
@property(nonatomic,strong)GHPullRequests *openPullRequests;
@property(nonatomic,strong)GHPullRequests *closedPullRequests;
@property(nonatomic,strong)GHMilestones *milestones;
@property(nonatomic,strong)GHLabels *labels;
@property(nonatomic,strong)GHForks *forks;
@property(nonatomic,strong)GHTags *tags;
@property(nonatomic,strong)GHBranches *branches;
@property(nonatomic,strong)GHReadme *readme;
@property(nonatomic,strong)GHEvents *events;
@property(nonatomic,strong)GHUsers *contributors;
@property(nonatomic,strong)GHUsers *stargazers;
@property(nonatomic,strong)GHUsers *assignees;
@property(nonatomic,readonly)GHUser *user;
@property(nonatomic,readonly)GHRepository *parent;
@property(nonatomic,readwrite)NSInteger forkCount;
@property(nonatomic,readwrite)NSInteger watcherCount;
@property(nonatomic,readwrite)BOOL isPrivate;
@property(nonatomic,readwrite)BOOL isFork;
@property(nonatomic,readwrite)BOOL hasIssues;
@property(nonatomic,readwrite)BOOL hasWiki;
@property(nonatomic,readwrite)BOOL hasDownloads;

- (id)initWithOwner:(NSString *)owner andName:(NSString *)name;
- (void)setOwner:(NSString *)owner andName:(NSString *)name;
- (void)checkAssignment:(GHUser *)user usingBlock:(void (^)(BOOL isAssignee))block;
@end