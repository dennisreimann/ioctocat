#import "GHResource.h"
#import "GHRef.h"
#import "GHCommit.h"
#import "GHTag.h"
#import "GHRepository.h"


@implementation GHRef

- (id)initWithRepo:(GHRepository *)theRepo andRef:(NSString *)theRef {
	self = [super init];
	if (self) {
		self.repository = theRepo;
		self.ref = theRef;
		self.resourcePath = [NSString stringWithFormat:kTagFormat, self.repository.owner, self.repository.name, self.ref];
	}
	return self;
}

#pragma mark Loading

- (void)setValues:(id)theDict {
	NSString *type = [theDict valueForKeyPath:@"object.type"];
	NSString *sha = [theDict valueForKeyPath:@"sha"];
	if ([type isEqualToString:@"commit"]) {
		self.object = [[GHCommit alloc] initWithRepository:self.repository andCommitID:sha];
	} else if ([type isEqualToString:@"tag"]) {
		self.object = [[GHTag alloc] initWithRepo:self.repository andSha:sha];
	}
}

@end