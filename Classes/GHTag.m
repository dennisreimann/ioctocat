#import "GHResource.h"
#import "GHTag.h"
#import "GHTree.h"
#import "GHCommit.h"
#import "GHRepository.h"
#import "iOctocat.h"
#import "NSURL_IOCExtensions.h"
#import "NSDictionary_IOCExtensions.h"


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
        self.htmlURL = [NSURL ioc_URLWithFormat:@"/%@/%@/tree/%@", self.repository.owner, self.repository.name, self.tag];
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
	NSString *tag = [dict ioc_stringOrNilForKey:@"tag"];
	NSString *sha = [dict ioc_stringOrNilForKeyPath:@"object.sha"];
	if (!tag) tag = [dict ioc_stringOrNilForKey:@"name"];
	if (!sha) sha = [dict ioc_stringOrNilForKeyPath:@"commit.sha"];
	self.tag = tag;
	self.message = [dict ioc_stringForKey:@"message"];
	self.taggerName = [dict ioc_stringForKeyPath:@"tagger.name"];
	self.taggerEmail = [dict ioc_stringForKeyPath:@"tagger.email"];
	self.taggerDate = [dict ioc_dateForKeyPath:@"tagger.date"];
	self.commit = [[GHCommit alloc] initWithRepository:self.repository andCommitID:sha];
}

@end