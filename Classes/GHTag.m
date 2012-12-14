#import "GHResource.h"
#import "GHTag.h"
#import "GHCommit.h"
#import "GHRepository.h"
#import "iOctocat.h"


@implementation GHTag

- (id)initWithRepo:(GHRepository *)repo andSha:(NSString *)sha {
	self = [super init];
	if (self) {
		self.repository = repo;
		self.sha = sha;
		self.resourcePath = [NSString stringWithFormat:kTagFormat, self.repository.owner, self.repository.name, self.sha];
	}
	return self;
}

#pragma mark Loading

- (void)setValues:(id)dict {
	self.tag = [dict valueForKey:@"tag"];
	self.message = [dict valueForKey:@"message"];
	self.taggerName = [dict valueForKeyPath:@"tagger.name"];
	self.taggerEmail = [dict valueForKeyPath:@"tagger.email"];
	self.taggerDate = [iOctocat parseDate:[dict valueForKey:@"tagger.date"]];
	self.commit = [[GHCommit alloc] initWithRepository:self.repository andCommitID:[dict valueForKey:@"object.sha"]];
}

@end