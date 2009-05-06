#import "GHUser.h"
#import "GHRepository.h"
#import "GravatarLoader.h"
#import "GHReposParserDelegate.h"
#import "GHUsersParserDelegate.h"
#import "ASIFormDataRequest.h"
#import "CJSONDeserializer.h"

@interface GHUser ()
- (void)parseXMLWithToken:(NSString *)token;
- (void)parseReposXML;
@end


@implementation GHUser

@synthesize name, login, email, company, blogURL, location, gravatar, repositoriesStatus, repositories, followingStatus;
@synthesize publicGistCount, privateGistCount, publicRepoCount, privateRepoCount, isAuthenticated, following;

- (id)init {
	[super init];
	self.status             = GHResourceStatusNotLoaded;
	self.repositoriesStatus = GHResourceStatusNotLoaded;
    self.followingStatus    = GHResourceStatusNotLoaded;
	isAuthenticated = NO;
	gravatarLoader = [[GravatarLoader alloc] initWithTarget:self andHandle:@selector(loadedGravatar:)];
	return self;
}

- (id)initWithLogin:(NSString *)theLogin {
	[self init];
	self.login = theLogin;
	self.gravatar = [UIImage imageWithContentsOfFile:self.cachedGravatarPath];
	return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHUser login:'%@' isAuthenticated:'%@' status:'%d' name:'%@' email:'%@' company:'%@' location:'%@' blogURL:'%@' publicRepoCount:'%d' privateRepoCount:'%d'>", login, isAuthenticated ? @"YES" : @"NO", status, name, email, company, location, blogURL, publicRepoCount, privateRepoCount];
}

- (BOOL)isFollowing:(GHUser *)anUser {
    if ( !self.isFollowingLoaded ) return NO;
    for ( GHUser *user in following ) {
        if ( [user.login caseInsensitiveCompare:anUser.login] ) return YES;
    }
	return NO;
}

// FIXME Currently just stubbed out, see the issue:
// http://github.com/dbloete/ioctocat/issues#issue/6
- (BOOL)isWatching:(GHRepository *)aRepository {
	return NO;
}

#pragma mark -
#pragma mark User loading

- (void)loadUser {
	if (self.isLoading) return;
	self.error = nil;
	self.status = GHResourceStatusLoading;
	[self performSelectorInBackground:@selector(parseXMLWithToken:) withObject:nil];
}

- (void)authenticateWithToken:(NSString *)theToken {
	if (self.isLoading) return;
	self.error = nil;
	self.status = GHResourceStatusLoading;
	[self performSelectorInBackground:@selector(parseXMLWithToken:) withObject:theToken];
}

- (void)parseXMLWithToken:(NSString *)token {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *userURLString = token ? [NSString stringWithFormat:kAuthenticateUserXMLFormat, login, login, token] : [NSString stringWithFormat:kUserXMLFormat, login];
	NSURL *userURL = [NSURL URLWithString:userURLString];
	GHUsersParserDelegate *parserDelegate = [[GHUsersParserDelegate alloc] initWithTarget:self andSelector:@selector(loadedUsers:)];
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:userURL];
	[parser setDelegate:parserDelegate];
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	[parser parse];
	[parser release];
	[parserDelegate release];
	[pool release];
}

- (void)loadedUsers:(id)theResult {
	if ([theResult isKindOfClass:[NSError class]]) {
		self.error = theResult;
	} else if ([(NSArray *)theResult count] > 0) {
		GHUser *user = [(NSArray *)theResult objectAtIndex:0];
		self.login = user.login;
		self.name = user.name;
		self.email = user.email;
		self.company = user.company;
		self.location = user.location;
		self.blogURL = user.blogURL;
		self.publicGistCount = user.publicGistCount;
		self.privateGistCount = user.privateGistCount;
		self.publicRepoCount = user.publicRepoCount;
		self.privateRepoCount = user.privateRepoCount;
		self.isAuthenticated = user.isAuthenticated;
		if (email) [gravatarLoader loadEmail:email withSize:44];
	}
	self.status = GHResourceStatusLoaded;
}

#pragma mark -
#pragma mark Repository loading

- (BOOL)isReposLoading {
	return repositoriesStatus == GHResourceStatusLoading;
}

- (BOOL)isReposLoaded {
	return repositoriesStatus == GHResourceStatusLoaded;
}

- (void)loadRepositories {
	self.repositoriesStatus = GHResourceStatusLoading;
	[self performSelectorInBackground:@selector(parseReposXML) withObject:nil];
}

- (void)parseReposXML {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *url = [NSString stringWithFormat:kUserReposFormat, login, @""];
	NSURL *reposURL = [NSURL URLWithString:url];
	GHReposParserDelegate *parserDelegate = [[GHReposParserDelegate alloc] initWithTarget:self andSelector:@selector(loadedRepositories:)];
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:reposURL];
	[parser setDelegate:parserDelegate];
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	[parser parse];
	[parser release];
	[parserDelegate release];
	[pool release];
}

- (void)loadedRepositories:(NSArray *)theRepositories {
	self.repositories = theRepositories;
	self.repositoriesStatus = GHResourceStatusLoaded;
}


#pragma mark -
#pragma mark Following loading

- (BOOL)isFollowingLoaded {
	return followingStatus == GHResourceStatusLoaded;
}

- (void)loadFollowing {
	self.followingStatus = GHResourceStatusLoading;
	[self performSelectorInBackground:@selector(parseFollowingJSON) withObject:nil];
}

// KUserFollowingJSONFormat
- (void)parseFollowingJSON {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *username = [defaults stringForKey:kUsernameDefaultsKey];
	NSString *token = [defaults stringForKey:kTokenDefaultsKey];
    
	NSString *url = [NSString stringWithFormat:KUserFollowingJSONFormat, username];
	NSURL *followingURL = [NSURL URLWithString:url];
	ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:followingURL ] autorelease];
	[request setPostValue:username forKey:@"login"];
	[request setPostValue:token forKey:@"token"];	
	[request start];	
    NSDictionary *followingDict = [[CJSONDeserializer deserializer] deserialize:[request responseData] error:nil];
    NSMutableArray *followingUsers = [[NSMutableArray alloc] init];
    for (NSString *userid in [followingDict objectForKey:@"users"]) {
        GHUser *user = [[GHUser alloc] initWithLogin:userid];
        [followingUsers addObject:user];
        [user release];
    }
    self.following = followingUsers;
	self.followingStatus = GHResourceStatusLoaded;
    [followingUsers release];
    [pool release];
}

#pragma mark -
#pragma mark Gravatar

- (void)loadedGravatar:(UIImage *)theImage {
	self.gravatar = theImage;
	[UIImagePNGRepresentation(theImage) writeToFile:self.cachedGravatarPath atomically:YES];
}

- (NSString *)cachedGravatarPath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [paths objectAtIndex:0];
	NSString *imageName = [NSString stringWithFormat:@"%@.png", login];
	return [documentsPath stringByAppendingPathComponent:imageName];
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[name release];
	[login release];
	[email release];
	[company release];
	[blogURL release];
	[location release];
	[gravatar release];
	[repositories release];
	[gravatarLoader release];
    [following release];
    [super dealloc];
}

@end
