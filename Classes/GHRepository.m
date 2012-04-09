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
@synthesize githubURL;
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
	return [[[[self class] alloc] initWithOwner:theOwner andName:theName] autorelease];
}

- (id)initWithOwner:(NSString *)theOwner andName:(NSString *)theName {
	[super init];
	[self setOwner:theOwner andName:theName];
	return self;
}

- (void)dealloc {
	[name release];
	[owner release];
	[descriptionText release];
	[githubURL release];
	[homepageURL release];
    [openIssues release];
    [closedIssues release];
    [forks release];
	[branches release];
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
    return [NSString stringWithFormat:@"<GHRepository name:'%@' owner:'%@' descriptionText:'%@' githubURL:'%@' homepageURL:'%@' isPrivate:'%@' isFork:'%@' forks:'%d' watchers:'%d'>", name, owner, descriptionText, githubURL, homepageURL, isPrivate ? @"YES" : @"NO", isFork ? @"YES" : @"NO", forkCount, watcherCount];
}

- (NSString *)repoId {
    return [NSString stringWithFormat:@"%@/%@", owner, name];
}

- (NSString *)repoIdAndStatus {
    return [NSString stringWithFormat:@"%@/%@/%@", owner, isPrivate ? @"private" : @"public", name];
}

- (NSURL *)resourceURL {
	// Dynamic resourceURL, because it depends on the
	// owner and name which isn't always available in advance
	return [NSURL URLWithFormat:kRepoFormat, owner, name];
}

- (void)setOwner:(NSString *)theOwner andName:(NSString *)theName {
	self.owner = theOwner;
	self.name = theName;
    // Forks
    self.forks = [GHForks forksWithRepository:self];
	// Branches
    self.branches = [GHBranches branchesWithRepository:self];
	// Issues
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
    
    self.githubURL = [NSURL URLWithString:[resource objectForKey:@"url"]];
    self.homepageURL = [NSURL smartURLFromString:[resource objectForKey:@"homepage"]];
    self.descriptionText = [resource objectForKey:@"description"];
    self.isFork = [[resource objectForKey:@"fork"] boolValue];
    self.isPrivate = [[resource objectForKey:@"private"] boolValue];
    self.forkCount = [[resource objectForKey:@"forks"] integerValue];
    self.watcherCount = [[resource objectForKey:@"watchers"] integerValue];
	self.pushedAtDate = [resource objectForKey:@"pushed_at"];
}

@end
