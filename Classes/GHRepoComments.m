#import "GHRepoComments.h"
#import "GHRepoComment.h"
#import "GHRepository.h"
#import "GHRepository.h"
#import "NSURL+Extensions.h"


@implementation GHRepoComments

+ (id)commentsWithRepo:(GHRepository *)theRepo andCommitID:(NSString *)theCommitID {
	return [[self.class alloc] initWithRepo:theRepo andCommitID:theCommitID];
}

- (id)initWithRepo:(GHRepository *)theRepo andCommitID:(NSString *)theCommitID {
	self = [super init];
	if (self) {
		self.repository = theRepo;
		self.commitID = theCommitID;
		self.comments = [NSMutableArray array];
	}
	return self;
}

- (NSURL *)resourcePath {
	// Dynamic resourcePath, because it depends on the
	// SHA which isn't always available in advance
	return [NSString stringWithFormat:kRepoCommentsFormat, self.repository.owner, self.repository.name, self.commitID];
}

- (void)setValues:(id)theResponse {
	NSMutableArray *resources = [NSMutableArray array];
	for (NSDictionary *dict in theResponse) {
		GHRepoComment *comment = [GHRepoComment commentWithRepo:self.repository andDictionary:dict];
		[resources addObject:comment];
	}
	self.comments = resources;
}

@end