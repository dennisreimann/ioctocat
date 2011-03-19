#import "GHUser.h"
#import "GHUsers.h"
#import "GHFeed.h"
#import "GHRepository.h"
#import "GHRepositories.h"
#import "GravatarLoader.h"
#import "ASIFormDataRequest.h"
#import "CJSONDeserializer.h"
#import "NSString+Extensions.h"
#import "iOctocat.h"


@interface GHUser ()
- (void)setFollowing:(NSString *)theMode forUser:(GHUser *)theUser;
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
@synthesize gravatarHash;
@synthesize gravatar;
@synthesize repositories;
@synthesize watchedRepositories;
@synthesize isAuthenticated;
@synthesize recentActivity;
@synthesize publicGistCount;
@synthesize privateGistCount;
@synthesize publicRepoCount;
@synthesize privateRepoCount;
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
	[gravatarHash release], gravatarHash = nil;
	[gravatar release], gravatar = nil;
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
    // URLs
    NSString *urlString = [NSString stringWithFormat:kUserFormat, login];
	NSString *repositoriesURLString = [NSString stringWithFormat:kUserReposFormat, login];
	NSString *watchedRepositoriesURLString = [NSString stringWithFormat:kUserWatchedReposFormat, login];
    NSString *followingURLString = [NSString stringWithFormat:kUserFollowingFormat, login];
    NSString *followersURLString = [NSString stringWithFormat:kUserFollowersFormat, login];
	NSString *activityFeedURLString = [NSString stringWithFormat:kUserFeedFormat, login];
    
	NSURL *repositoriesURL = [NSURL URLWithString:repositoriesURLString];
	NSURL *watchedRepositoriesURL = [NSURL URLWithString:watchedRepositoriesURLString];
    NSURL *followingURL = [NSURL URLWithString:followingURLString];
    NSURL *followersURL = [NSURL URLWithString:followersURLString];
	NSURL *activityFeedURL = [NSURL URLWithString:activityFeedURLString];
    
    self.resourceURL = [NSURL URLWithString:urlString];
	self.repositories = [GHRepositories repositoriesWithURL:repositoriesURL];
	self.watchedRepositories = [GHRepositories repositoriesWithURL:watchedRepositoriesURL];
    self.following = [[[GHUsers alloc] initWithUser:self andURL:followingURL] autorelease];
    self.followers = [[[GHUsers alloc] initWithUser:self andURL:followersURL] autorelease];
	self.recentActivity = [GHFeed resourceWithURL:activityFeedURL];
}

#pragma mark Loading

- (void)setValuesFromDict:(NSDictionary *)theDict {
    NSDictionary *resource = [theDict objectForKey:@"user"] ? [theDict objectForKey:@"user"] : theDict;
    
    if (![login isEqualToString:[resource objectForKey:@"login"]]) self.login = [resource objectForKey:@"login"];
    self.name = [resource objectForKey:@"name"];
    self.email = [resource objectForKey:@"email"];
    self.company = [resource objectForKey:@"company"];
    self.location = [resource objectForKey:@"location"];
    self.gravatarHash = [resource objectForKey:@"gravatar_id"];
    self.blogURL = [[resource objectForKey:@"blog"] isKindOfClass:[NSNull class]] ? nil : [NSURL URLWithString:[resource objectForKey:@"blog"]];
    self.publicGistCount = [[resource objectForKey:@"public_gist_count"] integerValue];
    self.privateGistCount = [[resource objectForKey:@"private_gist_count"] integerValue];
    self.publicRepoCount = [[resource objectForKey:@"public_repo_count"] integerValue];
    self.privateRepoCount = [[resource objectForKey:@"total_private_repo_count"] integerValue];
    self.isAuthenticated = [resource objectForKey:@"plan"] ? YES : NO;
    
    if (gravatarHash) [gravatarLoader loadHash:gravatarHash withSize:[[iOctocat sharedInstance] gravatarSize]];
}

#pragma mark Following

- (BOOL)isFollowing:(GHUser *)anUser {
	if (!following.isLoaded) [following loadData];
	return [following.users containsObject:anUser];
}

- (void)followUser:(GHUser *)theUser {
	[following.users addObject:theUser];
	[self setFollowing:kFollow forUser:theUser];
}

- (void)unfollowUser:(GHUser *)theUser {
	[following.users removeObject:theUser];
	[self setFollowing:kUnFollow forUser:theUser];
}

- (void)setFollowing:(NSString *)theMode forUser:(GHUser *)theUser {
	NSString *followingURLString = [NSString stringWithFormat:kUserFollowFormat, theMode, theUser.login];
	NSURL *followingURL = [NSURL URLWithString:followingURLString];
    ASIFormDataRequest *request = [GHResource authenticatedRequestForURL:followingURL];
	[request setDelegate:self];
	[request setRequestMethod:@"POST"];
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
	NSString *watchingURLString = [NSString stringWithFormat:kRepoWatchFormat, theMode, theRepository.owner, theRepository.name];
	NSURL *watchingURL = [NSURL URLWithString:watchingURLString];
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

- (void)loadedGravatar:(UIImage *)theImage {
	self.gravatar = theImage;
	[UIImagePNGRepresentation(theImage) writeToFile:[[iOctocat sharedInstance] cachedGravatarPathForIdentifier:self.login] atomically:YES];
}

@end
