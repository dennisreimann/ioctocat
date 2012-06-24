#import "GHRepository.h"
#import "GHResource.h"
#import "iOctocat.h"
#import "GHIssues.h"
#import "GHForks.h"
#import "GHBranches.h"
#import "NSURL+Extensions.h"


@implementation GHRepository

@synthesize name;
@synthesize owner;
@synthesize descriptionText;
@synthesize htmlURL;
@synthesize homepageURL;
@synthesize isPrivate;
@synthesize isFork;
@synthesize forks;
@synthesize watcherCount;
@synthesize forkCount;
@synthesize openIssues;
@synthesize closedIssues;
@synthesize branches;
@synthesize pushedAtDate;

+ (id)repositoryWithOwner:(NSString *)theOwner andName:(NSString *)theName {
	return [[[self.class alloc] initWithOwner:theOwner andName:theName] autorelease];
}

- (id)initWithOwner:(NSString *)theOwner andName:(NSString *)theName {
	[super init];
	[self setOwner:theOwner andName:theName];
	return self;
}

- (void)dealloc {
	[name release], name = nil;
	[owner release], owner = nil;
	[descriptionText release], descriptionText = nil;
	[htmlURL release], htmlURL = nil;
	[homepageURL release], homepageURL = nil;
    [openIssues release], openIssues = nil;
    [closedIssues release], closedIssues = nil;
    [forks release], forks = nil;
	[branches release], branches = nil;
    [super dealloc];
}

- (BOOL)isEqual:(id)anObject {
	return [self hash] == [anObject hash];
}

- (NSUInteger)hash {
	NSString *hashValue = [NSString stringWithFormat:@"%@/%@", [owner lowercaseString], [name lowercaseString]];
	return [hashValue hash];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHRepository name:'%@' owner:'%@' isPrivate:'%@' isFork:'%@'>", name, owner, isPrivate ? @"YES" : @"NO", isFork ? @"YES" : @"NO"];
}

- (NSString *)repoId {
    return [NSString stringWithFormat:@"%@/%@", owner, name];
}

- (NSString *)repoIdAndStatus {
    return [NSString stringWithFormat:@"%@/%@/%@", owner, isPrivate ? @"private" : @"public", name];
}

- (NSString *)resourcePath {
	// Dynamic resourceURL, because it depends on the
	// owner and name which isn't always available in advance
	return [NSString stringWithFormat:kRepoFormat, owner, name];
}

- (void)setOwner:(NSString *)theOwner andName:(NSString *)theName {
	self.owner = theOwner;
	self.name = theName;
    self.forks = [GHForks forksWithRepository:self];
    self.branches = [GHBranches branchesWithRepository:self];
	self.openIssues = [GHIssues issuesWithRepository:self andState:kIssueStateOpen];
	self.closedIssues = [GHIssues issuesWithRepository:self andState:kIssueStateClosed];
}

- (GHUser *)user {
	return [[iOctocat sharedInstance] userWithLogin:owner];
}

- (int)compareByRepoId:(GHRepository *)theOtherRepository {
    return [[self repoId] localizedCaseInsensitiveCompare:[theOtherRepository repoId]];
}

- (int)compareByRepoIdAndStatus:(GHRepository *)theOtherRepository {
    return [[self repoIdAndStatus] localizedCaseInsensitiveCompare:[theOtherRepository repoIdAndStatus]];
}

- (int)compareByName:(GHRepository *)theOtherRepository {
    return [[self name] localizedCaseInsensitiveCompare:[theOtherRepository name]];
}

#pragma mark Loading

- (void)setValuesFromDict:(NSDictionary *)theDict {
    NSDictionary *resource = [theDict objectForKey:@"repository"] ? [theDict objectForKey:@"repository"] : theDict;
    
    self.htmlURL = [NSURL URLWithString:[resource objectForKey:@"html_url"]];
    self.homepageURL = [NSURL smartURLFromString:[resource objectForKey:@"homepage"]];
    self.descriptionText = [resource objectForKey:@"description"];
    self.isFork = [[resource objectForKey:@"fork"] boolValue];
    self.isPrivate = [[resource objectForKey:@"private"] boolValue];
    self.forkCount = [[resource objectForKey:@"forks"] integerValue];
    self.watcherCount = [[resource objectForKey:@"watchers"] integerValue];
	self.pushedAtDate = [resource objectForKey:@"pushed_at"];
}

@end
