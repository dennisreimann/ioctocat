#import "GHRepoComments.h"
#import "GHRepoComment.h"
#import "GHRepository.h"


@interface GHRepoComments ()
@property(nonatomic,weak)GHRepository *repository;
@property(nonatomic,strong)NSString *commitID;
@end

@implementation GHRepoComments

- (id)initWithRepo:(GHRepository *)repo andCommitID:(NSString *)commitID {
	self = [super init];
	if (self) {
		self.repository = repo;
		self.commitID = commitID;
	}
	return self;
}

- (NSString *)resourcePath {
	// Dynamic resourcePath, because it depends on the
	// SHA which isn't always available in advance
	return [NSString stringWithFormat:kRepoCommentsFormat, self.repository.owner, self.repository.name, self.commitID];
}

- (void)setValues:(id)values {
    [super setValues:values];
	for (NSDictionary *dict in values) {
		GHRepoComment *comment = [[GHRepoComment alloc] initWithRepo:self.repository];
		[comment setValues:dict];
		[self addObject:comment];
	}
}

@end