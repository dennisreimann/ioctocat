#import "GHResource.h"
#import "GHRef.h"
#import "GHCommit.h"
#import "GHTag.h"
#import "GHRepository.h"


@implementation GHRef

+ (id)refWithRepo:(GHRepository *)theRepo andRef:(NSString *)theRef {
  return [[[self.class alloc] initWithRepo:theRepo andRef:theRef] autorelease];
}

- (id)initWithRepo:(GHRepository *)theRepo andRef:(NSString *)theRef {
	self = [super init];
	if (self) {
		self.repository = theRepo;
		self.ref = theRef;
		self.resourcePath = [NSString stringWithFormat:kTagFormat, self.repository.owner, self.repository.name, self.ref];
	}
	return self;
}

- (void)dealloc {
	[_repository release], _repository = nil;
	[_object release], _object = nil;
	[_ref release], _ref = nil;
	[super dealloc];
}

#pragma mark Loading

- (void)setValues:(id)theDict {
	NSString *type = [theDict valueForKeyPath:@"object.type"];
	NSString *sha = [theDict valueForKeyPath:@"sha"];
	if ([type isEqualToString:@"commit"]) {
		self.object = [GHCommit commitWithRepo:self.repository andSha:sha];
	} else if ([type isEqualToString:@"tag"]) {
		self.object = [GHTag tagWithRepo:self.repository andSha:sha];
	}
}

@end