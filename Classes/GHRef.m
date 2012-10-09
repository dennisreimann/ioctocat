#import "GHResource.h"
#import "GHRef.h"
#import "GHCommit.h"
#import "GHTag.h"
#import "GHRepository.h"


@implementation GHRef

@synthesize ref;
@synthesize repository;
@synthesize object;

+ (id)refWithRepo:(GHRepository *)theRepo andRef:(NSString *)theRef {
  return [[[self.class alloc] initWithRepo:theRepo andRef:theRef] autorelease];
}

- (id)initWithRepo:(GHRepository *)theRepo andRef:(NSString *)theRef {
	[super init];
	self.repository = theRepo;
	self.ref = theRef;
	self.resourcePath = [NSString stringWithFormat:kTagFormat, repository.owner, repository.name, ref];
	return self;
}

- (void)dealloc {
	[repository release], repository = nil;
	[ref release], ref = nil;
	[object release], object = nil;
	[super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<GHRef ref:'%@'>", ref];
}

#pragma mark Loading

- (void)setValuesFromDict:(NSDictionary *)theDict {
	NSString *type = [theDict valueForKeyPath:@"object.type"];
	NSString *sha = [theDict valueForKeyPath:@"sha"];
	if ([type isEqualToString:@"commit"]) {
		self.object = [GHCommit commitWithRepo:repository andSha:sha];
	} else if ([type isEqualToString:@"tag"]) {
		self.object = [GHTag tagWithRepo:repository andSha:sha];
	}
}

@end
