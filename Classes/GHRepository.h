#import <Foundation/Foundation.h>
#import "GHResource.h"
#import "GHUser.h"
#import "GHFeed.h"


@interface GHRepository : GHResource {
	NSString *name;
	NSString *owner;
	NSString *descriptionText;
	NSURL *githubURL;
	NSURL *homepageURL;
	NSInteger forks;
	NSInteger watchers;
	BOOL isPrivate;
	BOOL isFork;
	GHFeed *recentCommits;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *owner;
@property (nonatomic, retain) NSString *descriptionText;
@property (nonatomic, retain) NSURL *githubURL;
@property (nonatomic, retain) NSURL *homepageURL;
@property (nonatomic, retain) GHFeed *recentCommits;
@property (nonatomic, readwrite) NSInteger forks;
@property (nonatomic, readwrite) NSInteger watchers;
@property (nonatomic, readwrite) BOOL isPrivate;
@property (nonatomic, readwrite) BOOL isFork;
@property (nonatomic, readonly) GHUser *user;

- (id)initWithOwner:(NSString *)theOwner andName:(NSString *)theName;
- (void)setOwner:(NSString *)theOwner andName:(NSString *)theName;
- (void)loadRepository;
- (void)loadedRepositories:(id)theResult;

@end
