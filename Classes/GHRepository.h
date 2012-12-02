#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHIssues, GHForks, GHBranches, GHUser, GHReadme, GHEvents;

@interface GHRepository : GHResource

@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *owner;
@property(nonatomic,strong)NSString *descriptionText;
@property(nonatomic,strong)NSString *mainBranch;
@property(nonatomic,strong)NSURL *htmlURL;
@property(nonatomic,strong)NSURL *homepageURL;
@property(nonatomic,strong)GHIssues *openIssues;
@property(nonatomic,strong)GHIssues *closedIssues;
@property(nonatomic,strong)GHForks *forks;
@property(nonatomic,strong)GHBranches *branches;
@property(nonatomic,strong)GHReadme *readme;
@property(nonatomic,strong)GHEvents *events;
@property(weak, nonatomic,readonly)GHUser *user;
@property(nonatomic,readwrite)NSInteger forkCount;
@property(nonatomic,readwrite)NSInteger watcherCount;
@property(nonatomic,readwrite)BOOL isPrivate;
@property(nonatomic,readwrite)BOOL isFork;
@property(nonatomic,readwrite)BOOL hasIssues;
@property(nonatomic,readwrite)BOOL hasWiki;
@property(nonatomic,readwrite)BOOL hasDownloads;
@property (nonatomic, strong) NSDate *pushedAtDate;

+ (id)repositoryWithOwner:(NSString *)theOwner andName:(NSString *)theName;
- (id)initWithOwner:(NSString *)theOwner andName:(NSString *)theName;
- (void)setOwner:(NSString *)theOwner andName:(NSString *)theName;
- (int)compareByName:(GHRepository*)repo;
- (int)compareByRepoId:(GHRepository*)repo;
- (int)compareByRepoIdAndStatus:(GHRepository*)repo;
- (NSString *)repoId;

@end