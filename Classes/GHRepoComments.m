#import "GHRepoComments.h"
#import "GHRepoComment.h"
#import "GHRepository.h"
#import "GHRepository.h"
#import "NSURL+Extensions.h"


@implementation GHRepoComments

@synthesize comments;
@synthesize repository;
@synthesize commitID;

+ (id)commentsWithRepo:(GHRepository *)theRepo andCommitID:(NSString *)theCommitID {
	return [[[[self class] alloc] initWithRepo:theRepo andCommitID:theCommitID] autorelease];
}

- (id)initWithRepo:(GHRepository *)theRepo andCommitID:(NSString *)theCommitID {
	[super init];
	self.repository = theRepo;
	self.commitID = theCommitID;
	self.comments = [NSMutableArray array];
	return self;
}

- (void)dealloc {
	[comments release], comments = nil;
	[repository release], repository = nil;
	[commitID release], commitID = nil;
	
	[super dealloc];
}

- (NSURL *)resourcePath {
	// Dynamic resourcePath, because it depends on the
	// SHA which isn't always available in advance
	return [NSString stringWithFormat:kRepoCommentsFormat, repository.owner, repository.name, commitID];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHRepoComments owner:'%@' name:'%@' commitID:'%@'>", repository.owner, repository.name, commitID];
}

- (void)setValues:(id)theResponse {
    NSMutableArray *resources = [NSMutableArray array];
	for (NSDictionary *dict in theResponse) {
		GHRepoComment *comment = [[GHRepoComment alloc] initWithRepo:repository andDictionary:dict];
		[resources addObject:comment];
		[comment release];
	}
    self.comments = resources;
}

@end
