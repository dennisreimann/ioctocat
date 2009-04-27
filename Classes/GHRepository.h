#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHUser;

@interface GHRepository : GHResource {
	NSString *name;
	NSString *owner;
	NSString *descriptionText;
	NSURL *githubURL;
	NSURL *homepageURL;
	NSInteger forks;
	NSInteger watchers;
	NSArray *recentCommits;
	BOOL isPrivate;
	BOOL isFork;
	BOOL isRecentCommitsLoaded;
	BOOL isRecentCommitsLoading;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *owner;
@property (nonatomic, retain) NSString *descriptionText;
@property (nonatomic, retain) NSURL *githubURL;
@property (nonatomic, retain) NSURL *homepageURL;
@property (nonatomic, retain) NSArray *recentCommits;
@property (nonatomic, readwrite) NSInteger forks;
@property (nonatomic, readwrite) NSInteger watchers;
@property (nonatomic, readwrite) BOOL isPrivate;
@property (nonatomic, readwrite) BOOL isFork;
@property (nonatomic, readwrite) BOOL isRecentCommitsLoaded;
@property (nonatomic, readwrite) BOOL isRecentCommitsLoading;
@property (nonatomic, readonly) GHUser *user;

- (id)initWithOwner:(NSString *)theOwner andName:(NSString *)theName;
- (void)loadRepository;
- (void)loadedRepositories:(NSArray *)theRepositories;
- (void)loadRecentCommits;
- (void)loadedRecentCommits:(NSArray *)theCommits;

@end
