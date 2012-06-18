#import "GHRepoComments.h"
#import "GHRepoComment.h"
#import "GHRepository.h"
#import "GHRepository.h"
#import "NSURL+Extensions.h"


@implementation GHRepoComments

@synthesize comments;
@synthesize repository;
@synthesize sha;

+ (id)commentsWithRepo:(GHRepository *)theRepo andSha:(NSString *)theSha {
	return [[[[self class] alloc] initWithRepo:theRepo andSha:theSha] autorelease];
}

- (id)initWithRepo:(GHRepository *)theRepo andSha:(NSString *)theSha {
	[super init];
	self.repository = theRepo;
	self.sha = theSha;
	self.comments = [NSMutableArray array];
	return self;
}

- (void)dealloc {
	[comments release], comments = nil;
	[repository release], repository = nil;
	[sha release], sha = nil;
	[super dealloc];
}

- (NSURL *)resourceURL {
	// Dynamic resourceURL, because it depends on the
	// SHA which isn't always available in advance
	return [NSURL URLWithFormat:kRepoCommentsFormat, repository.owner, repository.name, sha];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHRepoComments owner:'%@' name:'%@' sha:'%@'>", repository.owner, repository.name, sha];
}

- (void)setValuesFromDict:(NSDictionary *)theDict {
    NSMutableArray *resources = [NSMutableArray array];
	for (NSDictionary *dict in theDict) {
		GHRepoComment *comment = [[GHRepoComment alloc] initWithRepo:repository andSha:sha andDictionary:dict];
		[resources addObject:comment];
		[comment release];
	}
    self.comments = resources;
}

@end
