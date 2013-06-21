#import "GHResource.h"
#import "GHRef.h"
#import "GHCommit.h"
#import "GHTag.h"
#import "GHRepository.h"
#import "NSDictionary_IOCExtensions.h"


@implementation GHRef

- (id)initWithRepo:(GHRepository *)repo andRef:(NSString *)ref {
	self = [super init];
	if (self) {
		self.repository = repo;
		self.ref = ref;
		self.resourcePath = [NSString stringWithFormat:kTagFormat, self.repository.owner, self.repository.name, self.ref];
	}
	return self;
}

#pragma mark Loading

- (void)setValues:(id)dict {
	NSString *type = [dict ioc_stringForKeyPath:@"object.type"];
	NSString *sha = [dict ioc_stringForKey:@"sha"];
	if ([type isEqualToString:@"commit"]) {
		self.object = [[GHCommit alloc] initWithRepository:self.repository andCommitID:sha];
	} else if ([type isEqualToString:@"tag"]) {
		self.object = [[GHTag alloc] initWithRepo:self.repository sha:sha];
	}
}

@end