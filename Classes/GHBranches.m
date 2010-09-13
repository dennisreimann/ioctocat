#import "GHBranches.h"
#import "GHBranch.h"
#import "GHRepository.h"
#import "ASIFormDataRequest.h"
#import "CJSONDeserializer.h"


@implementation GHBranches

@synthesize branches;
@synthesize repository;

+ (id)branchesWithRepository:(GHRepository *)theRepository {
	return [[[[self class] alloc] initWithRepository:theRepository] autorelease];
}

- (id)initWithRepository:(GHRepository *)theRepository {
	[super init];
	self.repository = theRepository;
	self.branches = [NSMutableArray array];
	NSString *urlString = [NSString stringWithFormat:kRepoBranchesJSONFormat, repository.owner, repository.name];
	self.resourceURL = [NSURL URLWithString:urlString];
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

- (void)parseData:(NSData *)data {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSError *parseError = nil;
    NSDictionary *dict = [[CJSONDeserializer deserializer] deserialize:data error:&parseError];
    NSMutableArray *resources = [NSMutableArray array];
	for (NSString *branchName in [[dict objectForKey:@"branches"] allKeys]) {
		GHBranch *branch = [[GHBranch alloc] initWithRepository:repository andName:branchName];
		branch.sha = [[dict objectForKey:@"branches"] objectForKey:branchName];
        [resources addObject:branch];
		[branch release];
    }
    id res = parseError ? (id)parseError : (id)resources;
	[self performSelectorOnMainThread:@selector(parsingFinished:) withObject:res waitUntilDone:YES];
    [pool release];
}

- (void)parsingFinished:(id)theResult {
	if ([theResult isKindOfClass:[NSError class]]) {
		self.error = theResult;
		self.loadingStatus = GHResourceStatusNotLoaded;
	} else {
		self.branches = theResult;
		self.loadingStatus = GHResourceStatusLoaded;
	}
}

@end
