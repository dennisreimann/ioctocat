#import "GHCommit.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "ASIFormDataRequest.h"
#import "CJSONDeserializer.h"


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
	return self;
}

- (void)dealloc {
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

- (void)loadCommit {
	if (self.isLoading) return;
	self.error = nil;
	self.loadingStatus = GHResourceStatusLoading;
	[self performSelectorInBackground:@selector(parseCommit) withObject:nil];
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
	DebugLog(@"Commit result: %@", result);
	[self performSelectorOnMainThread:@selector(loadedCommit:) withObject:result waitUntilDone:YES];
    [pool release];
}

- (void)loadedCommit:(id)theResult {
	if ([theResult isKindOfClass:[NSError class]]) {
		self.error = theResult;
	} else {
		self.message = [theResult objectForKey:@"message"];
		self.tree = [theResult objectForKey:@"tree"];
	}
	self.loadingStatus = GHResourceStatusLoaded;
}

@end
