#import "GHUser.h"
#import "GHUsers.h"
#import "GHOrganizations.h"
#import "GHFeed.h"
#import "GHRepository.h"
#import "GHRepositories.h"
#import "GHResource.h"
#import "GravatarLoader.h"
#import "ASIFormDataRequest.h"
#import "CJSONDeserializer.h"
#import "NSString+Extensions.h"
#import "NSURL+Extensions.h"
#import "iOctocat.h"


@interface GHUser ()
- (void)setFollowing:(BOOL)theMode forUser:(GHUser *)theUser;
- (void)setWatching:(NSString *)theMode forRepository:(GHRepository *)theRepository;
- (void)followToggleFinished:(ASIHTTPRequest *)request;
- (void)followToggleFailed:(ASIHTTPRequest *)request;
- (void)watchToggleFinished:(ASIHTTPRequest *)request;
- (void)watchToggleFailed:(ASIHTTPRequest *)request;
@end


@implementation GHUser

@synthesize name;
@synthesize login;
@synthesize email;
@synthesize company;
@synthesize blogURL;
@synthesize location;
@synthesize gravatarURL;
@synthesize gravatar;
@synthesize organizations;
@synthesize repositories;
@synthesize watchedRepositories;
@synthesize isAuthenticated;
@synthesize recentActivity;
@synthesize publicGistCount;
@synthesize privateGistCount;
@synthesize publicRepoCount;
@synthesize privateRepoCount;
@synthesize followingCount;
@synthesize followersCount;
@synthesize following;
@synthesize followers;

+ (id)userWithLogin:(NSString *)theLogin {
	return [[[[self class] alloc] initWithLogin:theLogin] autorelease];
}

- (id)initWithLogin:(NSString *)theLogin {
	[self init];
	self.login = theLogin;
	self.gravatar = [UIImage imageWithContentsOfFile:[[iOctocat sharedInstance] cachedGravatarPathForIdentifier:self.login]];
	self.isAuthenticated = NO;
	gravatarLoader = [[GravatarLoader alloc] initWithTarget:self andHandle:@selector(loadedGravatar:)];
	return self;
}

- (void)dealloc {
	[name release], name = nil;
	[login release], login = nil;
	[email release], email = nil;
	[company release], company = nil;
	[blogURL release], blogURL = nil;
	[location release], location = nil;
    [gravatarLoader release], gravatarLoader = nil;
	[gravatarURL release], gravatarURL = nil;
	[gravatar release], gravatar = nil;
	[organizations release], organizations = nil;
	[repositories release], repositories = nil;
	[watchedRepositories release], watchedRepositories = nil;
	[recentActivity release], recentActivity = nil;
    [following release], following = nil;
    [followers release], followers = nil;
    [super dealloc];
}

- (NSUInteger)hash {
	NSString *hashValue = [login lowercaseString];
	return [hashValue hash];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHUser login:'%@' isAuthenticated:'%@' status:'%d' name:'%@' email:'%@' company:'%@' location:'%@' blogURL:'%@' publicRepoCount:'%d' privateRepoCount:'%d'>", login, isAuthenticated ? @"YES" : @"NO", loadingStatus, name, email, company, location, blogURL, publicRepoCount, privateRepoCount];
}

- (int)compareByName:(GHUser *)theOtherUser {
    return [login localizedCaseInsensitiveCompare:[theOtherUser login]];
}

- (void)setLogin:(NSString *)theLogin {
	[theLogin retain];
	[login release];
	login = theLogin;
    
    NSURL *repositoriesURL = [NSURL URLWithFormat:kUserReposFormat, login];
	NSURL *organizationsURL = [NSURL URLWithFormat:kOrganizationsFormat, login];
	NSURL *watchedRepositoriesURL = [NSURL URLWithFormat:kUserWatchedReposFormat, login];
    NSURL *followingURL = [NSURL URLWithFormat:kUserFollowingFormat, login];
    NSURL *followersURL = [NSURL URLWithFormat:kUserFollowersFormat, login];
	NSURL *activityFeedURL = [NSURL URLWithFormat:kUserFeedFormat, login];

    self.resourceURL = [NSURL URLWithFormat:kUserFormat, login];
	self.organizations = [GHOrganizations organizationsWithUser:self andURL:organizationsURL];
	self.repositories = [GHRepositories repositoriesWithURL:repositoriesURL];
	self.watchedRepositories = [GHRepositories repositoriesWithURL:watchedRepositoriesURL];
    self.following = [GHUsers usersWithURL:followingURL];
    self.followers = [GHUsers usersWithURL:followersURL];
	self.recentActivity = [GHFeed resourceWithURL:activityFeedURL];
}

#pragma mark Loading

- (void)setValuesFromDict:(NSDictionary *)theDict {
    if (![login isEqualToString:[theDict objectForKey:@"login"]]) self.login = [theDict objectForKey:@"login"];
    self.name = [[theDict objectForKey:@"name"] isKindOfClass:[NSNull class]] ? nil : [theDict objectForKey:@"name"];
    NSString *mail = [theDict objectForKey:@"email"];
    if (![mail isKindOfClass:[NSNull class]] && ![mail isEmpty]) {
        self.email = mail;
    }
    self.company = [[theDict objectForKey:@"company"] isKindOfClass:[NSNull class]] ? nil : [theDict objectForKey:@"company"];
    self.location = [[theDict objectForKey:@"location"] isKindOfClass:[NSNull class]] ? nil : [theDict objectForKey:@"location"];
    self.blogURL = [NSURL smartURLFromString:[theDict objectForKey:@"blog"]];
    self.publicGistCount = [[theDict objectForKey:@"public_gists"] integerValue];
    self.privateGistCount = [[theDict objectForKey:@"private_gists"] integerValue];
    self.publicRepoCount = [[theDict objectForKey:@"public_repos"] integerValue];
    self.privateRepoCount = [[theDict objectForKey:@"total_private_repos"] integerValue];
    self.followersCount = [[theDict objectForKey:@"followers"] integerValue];
    self.followingCount = [[theDict objectForKey:@"following"] integerValue];
    self.isAuthenticated = [theDict objectForKey:@"plan"] ? YES : NO;
    self.gravatarURL = [NSURL URLWithString:[theDict objectForKey:@"avatar_url"]];
    // gravatar_url will soon be deprecated by the GitHub API
    if (!self.gravatarURL && ![[theDict objectForKey:@"gravatar_url"] isKindOfClass:[NSNull class]]) {
        self.gravatarURL = [NSURL URLWithString:[theDict objectForKey:@"gravatar_url"]];
    }
}

#pragma mark Following

- (BOOL)isFollowing:(GHUser *)anUser {
	if (!following.isLoaded) [following loadData];
	return [following.users containsObject:anUser];
}

- (void)followUser:(GHUser *)theUser {
	[following.users addObject:theUser];
	[self setFollowing:YES forUser:theUser];
}

- (void)unfollowUser:(GHUser *)theUser {
	[following.users removeObject:theUser];
	[self setFollowing:NO forUser:theUser];
}

- (void)setFollowing:(BOOL)follow forUser:(GHUser *)theUser {
	NSURL *followingURL = [NSURL URLWithFormat:kUserFollowFormat, theUser.login];
    ASIFormDataRequest *request = [GHResource authenticatedRequestForURL:followingURL];
	[request setDelegate:self];
	[request setRequestMethod:follow ? @"PUT" : @"DELETE"];
	[request setDidFinishSelector:@selector(followToggleFinished:)];
	[request setDidFailSelector:@selector(followToggleFailed:)];
	[[iOctocat queue] addOperation:request];
}

- (void)followToggleFinished:(ASIHTTPRequest *)request {
	DJLog(@"Follow toggle %@ finished: %@", [request url], [request responseString]);
	self.following.loadingStatus = GHResourceStatusNotProcessed;
    [self.following loadData];
}

- (void)followToggleFailed:(ASIHTTPRequest *)request {
	DJLog(@"Follow toggle %@ failed: %@", [request url], [request error]);
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not change following status." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

#pragma mark Watching

- (BOOL)isWatching:(GHRepository *)aRepository {
	if (!watchedRepositories.isLoaded) [watchedRepositories loadData];
	return [watchedRepositories.repositories containsObject:aRepository];
}

- (void)watchRepository:(GHRepository *)theRepository {
	[watchedRepositories.repositories addObject:theRepository];
	[self setWatching:kWatch forRepository:theRepository];
}

- (void)unwatchRepository:(GHRepository *)theRepository {
	[watchedRepositories.repositories removeObject:theRepository];
	[self setWatching:kUnWatch forRepository:theRepository];
}

- (void)setWatching:(NSString *)theMode forRepository:(GHRepository *)theRepository {
	NSURL *watchingURL = [NSURL URLWithFormat:kRepoWatchFormat, theMode, theRepository.owner, theRepository.name];
    ASIFormDataRequest *request = [GHResource authenticatedRequestForURL:watchingURL];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(watchToggleFinished:)];
	[request setDidFailSelector:@selector(watchToggleFailed:)];
	[[iOctocat queue] addOperation:request];
}

- (void)watchToggleFinished:(ASIHTTPRequest *)request {
	DJLog(@"Watch toggle %@ finished: %@", [request url], [request responseString]);
	self.watchedRepositories.loadingStatus = GHResourceStatusNotProcessed;
    [self.watchedRepositories loadData];
}

- (void)watchToggleFailed:(ASIHTTPRequest *)request {
	DJLog(@"Watch toggle %@ failed: %@", [request url], [request error]);
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not change watching status." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

#pragma mark Gravatar

- (void)setGravatarURL:(NSURL *)theURL {
    [theURL retain];
	[gravatarURL release];
	gravatarURL = theURL;

	if (gravatarURL) {
        [gravatarLoader loadURL:gravatarURL];
    }
}

- (void)loadedGravatar:(UIImage *)theImage {
	self.gravatar = theImage;
	[UIImagePNGRepresentation(theImage) writeToFile:[[iOctocat sharedInstance] cachedGravatarPathForIdentifier:self.login] atomically:YES];
}

@end
