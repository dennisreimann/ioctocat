#import "GHBranches.h"
#import "GHBranch.h"
#import "GHRepository.h"
#import "ASIFormDataRequest.h"
#import "CJSONDeserializer.h"


@interface GHBranches ()
- (void)parseBranches;
@end


@implementation GHBranches

@synthesize branches;
@synthesize repository;

- (id)initWithRepository:(GHRepository *)theRepository {
	[super init];
	self.repository = theRepository;
	self.branches = [NSMutableArray array];
	return self;
}

- (void)dealloc {
	[branches release], branches = nil;
	[repository release], repository = nil;
	[super dealloc];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHBranches repository:'%@'>", repository];
}

- (void)loadBranches {
	if (self.isLoading) return;
	self.error = nil;
	self.loadingStatus = GHResourceStatusLoading;
	[self performSelectorInBackground:@selector(parseBranches) withObject:nil];
}

- (void)parseBranches {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *urlString = [NSString stringWithFormat:kRepoBranchesJSONFormat, repository.owner, repository.name];
	NSURL *branchesURL = [NSURL URLWithString:urlString];
    ASIFormDataRequest *request = [GHResource authenticatedRequestForURL:branchesURL];    
	[request start];
	NSError *parseError = nil;
    NSDictionary *dict = [[CJSONDeserializer deserializer] deserialize:[request responseData] error:&parseError];
    NSMutableArray *resources = [NSMutableArray array];
	for (NSString *branchName in [[dict objectForKey:@"branches"] allKeys]) {
		GHBranch *branch = [[GHBranch alloc] initWithRepository:repository andName:branchName];
		branch.sha = [[dict objectForKey:@"branches"] objectForKey:branchName];
        [resources addObject:branch];
		[branch release];
    }
    id res = parseError ? (id)parseError : (id)resources;
	[self performSelectorOnMainThread:@selector(loadedBranches:) withObject:res waitUntilDone:YES];
    [pool release];
}

- (void)loadedBranches:(id)theResult {
	if ([theResult isKindOfClass:[NSError class]]) {
		self.error = theResult;
		self.loadingStatus = GHResourceStatusNotLoaded;
	} else {
		self.branches = theResult;
		self.loadingStatus = GHResourceStatusLoaded;
	}
}

@end
