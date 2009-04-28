#import "GHUser.h"
#import "GHRepository.h"
#import "GravatarLoader.h"
#import "GHReposParserDelegate.h"
#import "GHUsersParserDelegate.h"


@interface GHUser ()
- (void)parseXML;
- (void)parseReposXML;
@end


@implementation GHUser

@synthesize name, login, email, company, blogURL, location, gravatar;
@synthesize repositoriesStatus, repositories;

- (id)init {
	[super init];
	self.status = GHResourceStatusNotLoaded;
	self.repositoriesStatus = GHResourceStatusNotLoaded;
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
    return [NSString stringWithFormat:@"<GHUser login:'%@' name:'%@' email:'%@' company:'%@' location:'%@' blogURL:'%@'>", login, name, email, company, location, blogURL];
}

#pragma mark -
#pragma mark User loading

- (void)loadUser {
	if (self.isLoading) return;
	self.error = nil;
	self.status = GHResourceStatusLoading;
	[self performSelectorInBackground:@selector(parseXML) withObject:nil];
}

- (void)parseXML {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *userURLString = [NSString stringWithFormat:kUserXMLFormat, login];
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
		self.status = GHResourceStatusNotLoaded;
	} else {
		self.status = GHResourceStatusLoaded;
		if ([(NSArray *)theResult count] == 0) return;
		GHUser *user = [(NSArray *)theResult objectAtIndex:0];
		self.login = user.login;
		self.name = user.name;
		self.email = user.email;
		self.company = user.company;
		self.location = user.location;
		self.blogURL = user.blogURL;
		self.status = GHResourceStatusLoaded;
		if (email) [gravatarLoader loadEmail:email withSize:44];
	}
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
#pragma mark Gravatar

- (void)loadedGravatar:(UIImage *)theImage {
	if (![theImage isKindOfClass:[UIImage class]]) return;
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
    [super dealloc];
}

@end
