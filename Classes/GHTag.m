#import "GHResource.h"
#import "GHTag.h"
#import "GHTree.h"
#import "GHCommit.h"
#import "GHRepository.h"
#import "iOctocat.h"
#import "NSURL+Extensions.h"
#import "NSDictionary+Extensions.h"


@interface GHTag () {
    GHTree *_tree;
}
@end


@implementation GHTag

- (id)initWithRepo:(GHRepository *)repo sha:(NSString *)sha {
	self = [super init];
	if (self) {
		self.repository = repo;
		self.sha = sha;
		self.tag = sha;
		self.resourcePath = [NSString stringWithFormat:kTagFormat, self.repository.owner, self.repository.name, self.sha];
	}
	return self;
}

- (NSURL *)htmlURL {
    if (!_htmlURL) {
        self.htmlURL = [NSURL URLWithFormat:@"/%@/%@/tree/%@", self.repository.owner, self.repository.name, self.tag];
    }
    return _htmlURL;
}

- (GHTree *)tree {
    if (!_tree) {
        _tree = [[GHTree alloc] initWithRepo:self.repository path:@"" ref:self.tag];
    }
    return _tree;
}

#pragma mark Loading

- (void)setValues:(id)dict {
	NSString *tag = [dict safeStringOrNilForKey:@"tag"];
	NSString *sha = [dict safeStringOrNilForKeyPath:@"object.sha"];
	if (!tag) tag = [dict safeStringOrNilForKey:@"name"];
	if (!sha) sha = [dict safeStringOrNilForKeyPath:@"commit.sha"];
	self.tag = tag;
	self.message = [dict safeStringForKey:@"message"];
	self.taggerName = [dict safeStringForKeyPath:@"tagger.name"];
	self.taggerEmail = [dict safeStringForKeyPath:@"tagger.email"];
	self.taggerDate = [dict safeDateForKeyPath:@"tagger.date"];
	self.commit = [[GHCommit alloc] initWithRepository:self.repository andCommitID:sha];
}

@end