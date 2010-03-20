#import "GHCommit.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "ASIFormDataRequest.h"
#import "CJSONDeserializer.h"
#import "iOctocat.h"


@interface GHCommit ()
- (void)parseCommit;
- (void)loadedCommit:(id)theResult;
@end


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

- (id)initWithRepository:(GHRepository *)theRepository andCommitID:(NSString *)theCommitID {
	[super init];
	self.repository = theRepository;
	self.commitID = theCommitID;
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
			[self performSelectorInBackground:@selector(parseCommit) withObject:nil];
		} else if (repository.error) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading error" message:@"Could not load the repository" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
}

- (void)loadCommit {
	if (self.isLoading) return;
	self.error = nil;
	self.loadingStatus = GHResourceStatusLoading;
	if (repository.isLoaded) {
		[self performSelectorInBackground:@selector(parseCommit) withObject:nil];
	} else {
		[repository loadRepository];
	}
}

- (void)parseCommit {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *baseString = repository.isPrivate ? kPrivateRepoCommitJSONFormat : kPublicRepoCommitJSONFormat;
	NSString *urlString = [NSString stringWithFormat:baseString, repository.owner, repository.name, commitID];
	NSURL *url = [NSURL URLWithString:urlString];
    ASIFormDataRequest *request = [GHResource authenticatedRequestForURL:url];    
	[request start];
	NSError *parseError = nil;
    NSDictionary *dict = [[CJSONDeserializer deserializer] deserialize:[request responseData] error:&parseError];
    id result = parseError ? (id)parseError : (id)[dict objectForKey:@"commit"];
	DJLog(@"Commit result: %@", result);
	[self performSelectorOnMainThread:@selector(loadedCommit:) withObject:result waitUntilDone:YES];
    [pool release];
}

- (void)loadedCommit:(id)theResult {
	if ([theResult isKindOfClass:[NSError class]]) {
		self.error = theResult;
	} else {
		NSString *authorLogin = [[theResult objectForKey:@"author"] objectForKey:@"login"];
		NSString *committerLogin = [[theResult objectForKey:@"committer"] objectForKey:@"login"];
		self.author = [[iOctocat sharedInstance] userWithLogin:authorLogin];
		self.committer = [[iOctocat sharedInstance] userWithLogin:committerLogin];
		self.committedDate = [[iOctocat sharedInstance] parseDate:[theResult objectForKey:@"committed_date"]];
		self.authoredDate = [[iOctocat sharedInstance] parseDate:[theResult objectForKey:@"authored_date"]];
		self.message = [theResult objectForKey:@"message"];
		self.tree = [theResult objectForKey:@"tree"];
		self.added = [theResult objectForKey:@"added"];
		self.modified = [theResult objectForKey:@"modified"];
		self.removed = [theResult objectForKey:@"removed"];
	}
	self.loadingStatus = GHResourceStatusLoaded;
}

@end
