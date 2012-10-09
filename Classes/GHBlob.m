#import "GHResource.h"
#import "GHBlob.h"
#import "GHRepository.h"


@implementation GHBlob

@synthesize sha;
@synthesize repository;
@synthesize encoding;
@synthesize content;
@synthesize path;
@synthesize mode;
@synthesize size;

+ (id)blobWithRepo:(GHRepository *)theRepo andSha:(NSString *)theSha {
  return [[[self.class alloc] initWithRepo:theRepo andSha:theSha] autorelease];
}

- (id)initWithRepo:(GHRepository *)theRepo andSha:(NSString *)theSha {
	[super init];
	self.repository = theRepo;
	self.sha = theSha;
	self.resourcePath = [NSString stringWithFormat:kBlobFormat, repository.owner, repository.name, sha];
	return self;
}

- (void)dealloc {
	[repository release], repository = nil;
	[sha release], sha = nil;
	[encoding release], encoding = nil;
	[content release], content = nil;
	[path release], path = nil;
	[mode release], mode = nil;
	[super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<GHBlob sha:'%@'>", sha];
}

#pragma mark Loading

- (void)setValuesFromDict:(NSDictionary *)theDict {
	self.encoding = [theDict valueForKey:@"encoding"];
	self.content = [theDict valueForKey:@"content"];
	self.size = [[theDict valueForKey:@"size"] integerValue];
}

@end
