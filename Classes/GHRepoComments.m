#import "GHRepoComments.h"
#import "GHRepoComment.h"
#import "GHRepository.h"
#import "GHRepository.h"
#import "NSURL+Extensions.h"


@implementation GHRepoComments

- (id)initWithRepo:(GHRepository *)theRepo andCommitID:(NSString *)theCommitID {
	self = [super init];
	if (self) {
		self.repository = theRepo;
		self.commitID = theCommitID;
	}
	return self;
}

- (NSURL *)resourcePath {
	// Dynamic resourcePath, because it depends on the
	// SHA which isn't always available in advance
	return [NSString stringWithFormat:kRepoCommentsFormat, self.repository.owner, self.repository.name, self.commitID];
}

- (void)setValues:(id)values {
	self.items = [NSMutableArray array];
	for (NSDictionary *dict in values) {
		GHRepoComment *comment = [[GHRepoComment alloc] initWithRepo:self.repository andDictionary:dict];
		[self addObject:comment];
	}
}

@end