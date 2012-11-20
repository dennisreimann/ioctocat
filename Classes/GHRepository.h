#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHIssues, GHForks, GHBranches, GHUser, GHReadme, GHEvents;

@interface GHRepository : GHResource {
	NSString *name;
	NSString *owner;
	NSString *descriptionText;
	NSString *mainBranch;
	NSURL *htmlURL;
	NSURL *homepageURL;
	NSInteger forkCount;
	NSInteger watcherCount;
	GHIssues *openIssues;
	GHIssues *closedIssues;
	GHForks *forks;
	GHBranches *branches;
	GHReadme *readme;
	GHEvents *events;
	BOOL isPrivate;
	BOOL isFork;
	BOOL hasIssues;
	BOOL hasWiki;
	BOOL hasDownloads;
}

@property(nonatomic,retain)NSString *name;
@property(nonatomic,retain)NSString *owner;
@property(nonatomic,retain)NSString *descriptionText;
@property(nonatomic,retain)NSString *mainBranch;
@property(nonatomic,retain)NSURL *htmlURL;
@property(nonatomic,retain)NSURL *homepageURL;
@property(nonatomic,retain)GHIssues *openIssues;
@property(nonatomic,retain)GHIssues *closedIssues;
@property(nonatomic,retain)GHForks *forks;
@property(nonatomic,retain)GHBranches *branches;
@property(nonatomic,retain)GHReadme *readme;
@property(nonatomic,retain)GHEvents *events;
@property(nonatomic,readonly)GHUser *user;
@property(nonatomic,readwrite)NSInteger forkCount;
@property(nonatomic,readwrite)NSInteger watcherCount;
@property(nonatomic,readwrite)BOOL isPrivate;
@property(nonatomic,readwrite)BOOL isFork;
@property(nonatomic,readwrite)BOOL hasIssues;
@property(nonatomic,readwrite)BOOL hasWiki;
@property(nonatomic,readwrite)BOOL hasDownloads;
@property (nonatomic, retain) NSDate *pushedAtDate;

+ (id)repositoryWithOwner:(NSString *)theOwner andName:(NSString *)theName;
- (id)initWithOwner:(NSString *)theOwner andName:(NSString *)theName;
- (void)setOwner:(NSString *)theOwner andName:(NSString *)theName;
- (int)compareByName:(GHRepository*)repo;
- (int)compareByRepoId:(GHRepository*)repo;
- (int)compareByRepoIdAndStatus:(GHRepository*)repo;
- (NSString *)repoId;

@end