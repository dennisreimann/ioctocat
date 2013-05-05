#import "GHResource.h"
#import "GHSubmodule.h"
#import "GHRepository.h"
#import "GHTree.h"
#import "NSString+Extensions.h"
#import "NSDictionary+Extensions.h"


@interface GHSubmodule () {
    GHTree *_tree;
}
@end


@implementation GHSubmodule

- (id)initWithRepo:(GHRepository *)repo path:(NSString *)path sha:(NSString *)sha {
	self = [super init];
	if (self) {
		self.repository = repo;
		self.path = path;
		self.sha = sha;
		self.resourcePath = [NSString stringWithFormat:kTreeFormat, self.repository.owner, self.repository.name, self.sha];
	}
	return self;
}

- (NSString *)shortenedSha {
    return [self.sha substringToIndex:7];
}

- (GHTree *)tree {
    if (!_tree) {
        _tree = [[GHTree alloc] initWithRepo:self.repository path:@"" ref:self.sha];
    }
    return _tree;
}

#pragma mark Loading

- (void)setValues:(id)values {
	self.sha = [values safeStringForKey:@"sha"];
	self.path = [values safeStringForKey:@"path"];
	self.name = [values safeStringOrNilForKey:@"name"];
}

@end