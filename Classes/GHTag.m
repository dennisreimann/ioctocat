#import "GHResource.h"
#import "GHTag.h"
#import "GHCommit.h"
#import "GHRepository.h"
#import "iOctocat.h"


@implementation GHTag

- (id)initWithRepo:(GHRepository *)theRepo andSha:(NSString *)theSha {
	self = [super init];
	if (self) {
		self.repository = theRepo;
		self.sha = theSha;
		self.resourcePath = [NSString stringWithFormat:kTagFormat, self.repository.owner, self.repository.name, self.sha];
	}
	return self;
}

#pragma mark Loading

- (void)setValues:(id)theDict {
	self.tag = [theDict valueForKey:@"tag"];
	self.message = [theDict valueForKey:@"message"];
	self.taggerName = [theDict valueForKeyPath:@"tagger.name"];
	self.taggerEmail = [theDict valueForKeyPath:@"tagger.email"];
	self.taggerDate = [iOctocat parseDate:[theDict valueForKey:@"tagger.date"]];
	self.commit = [[GHCommit alloc] initWithRepository:self.repository andCommitID:[theDict valueForKey:@"object.sha"]];
}

@end