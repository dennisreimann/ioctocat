#import "GHCommit.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "ASIFormDataRequest.h"
#import "CJSONDeserializer.h"
#import "iOctocat.h"


@implementation GHCommit

@synthesize commitID;
@synthesize tree;
@synthesize message;
@synthesize commitURL;
@synthesize authorName;
@synthesize authorEmail;
@synthesize committerName;
@synthesize committerEmail;
@synthesize committedDate;
@synthesize authoredDate;
@synthesize added;
@synthesize modified;
@synthesize removed;
@synthesize parents;
@synthesize author;
@synthesize committer;
@synthesize repository;

+ (id)commitWithRepository:(GHRepository *)theRepository andCommitID:(NSString *)theCommitID {
	return [[[[self class] alloc] initWithRepository:theRepository andCommitID:theCommitID] autorelease];
}

- (id)initWithRepository:(GHRepository *)theRepository andCommitID:(NSString *)theCommitID {
	[super init];
	self.repository = theRepository;
	self.commitID = theCommitID;
	
	// Build Resource URL
	NSString *baseString = repository.isPrivate ? kRepoPrivateCommitFormat : kRepoPublicCommitFormat;
	NSString *urlString = [NSString stringWithFormat:baseString, repository.owner, repository.name, commitID];
	self.resourceURL = [NSURL URLWithString:urlString];
	
	[repository addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	return self;
}

- (void)dealloc {
	[repository removeObserver:self forKeyPath:kResourceLoadingStatusKeyPath];
	[commitID release], commitID = nil;
    [tree release], tree = nil;
    [message release], message = nil;
    [commitURL release], commitURL = nil;
    [authorName release], authorName = nil;
    [authorEmail release], authorEmail = nil;
    [committerName release], committerName = nil;
    [committerEmail release], committerEmail = nil;
    [committedDate release], committedDate = nil;
    [authoredDate release], authoredDate = nil;
    [added release], added = nil;
    [modified release], modified = nil;
    [removed release], removed = nil;
    [parents release], parents = nil;
    [author release], author = nil;
    [committer release], committer = nil;
    [repository release], repository = nil;
	[super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		if (repository.isLoaded) {
			[self loadData];
		} else if (repository.error) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading error" message:@"Could not load the repository" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
}

- (void)loadData {
	if (self.isLoading) return;
	self.error = nil;
	if (repository.isLoaded) {
		self.loadingStatus = GHResourceStatusProcessing;
		// Send the request
		ASIFormDataRequest *request = [GHResource authenticatedRequestForURL:resourceURL];
		[request setDelegate:self];
		[request setDidFinishSelector:@selector(loadingFinished:)];
		[request setDidFailSelector:@selector(loadingFailed:)];
		DJLog(@"Loading URL: %@", [request url]);
		[[iOctocat queue] addOperation:request];
	} else {
		[repository loadData];
	}
}

- (void)setValuesFromDict:(NSDictionary *)theDict {
    NSDictionary *resource = [theDict objectForKey:@"commit"];
	
    NSString *authorLogin = [[resource objectForKey:@"author"] objectForKey:@"login"];
    NSString *committerLogin = [[resource objectForKey:@"committer"] objectForKey:@"login"];
    
    self.author = [[iOctocat sharedInstance] userWithLogin:authorLogin];
    self.committer = [[iOctocat sharedInstance] userWithLogin:committerLogin];
    self.committedDate = [iOctocat parseDate:[resource objectForKey:@"committed_date"] withFormat:kISO8601TimeFormat];
    self.authoredDate = [iOctocat parseDate:[resource objectForKey:@"authored_date"] withFormat:kISO8601TimeFormat];
    self.message = [resource objectForKey:@"message"];
    self.tree = [resource objectForKey:@"tree"];
    self.added = [resource objectForKey:@"added"];
    self.modified = [resource objectForKey:@"modified"];
    self.removed = [resource objectForKey:@"removed"];
}

@end
