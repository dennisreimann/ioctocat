#import "GHResource.h"
#import "GHBlob.h"
#import "GHRepository.h"
#import "NSString+Extensions.h"
#import "MF_Base64Additions.h"


@implementation GHBlob

@synthesize sha;
@synthesize repository;
@synthesize encoding;
@synthesize content;
@synthesize contentData;
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
	self.resourcePath = [NSString stringWithFormat:kBlobFormat, repository.owner, repository.name, [sha stringByEscapingForURLArgument]];
	return self;
}

- (void)dealloc {
	[repository release], repository = nil;
	[sha release], sha = nil;
	[encoding release], encoding = nil;
	[content release], content = nil;
	[contentData release], contentData = nil;
	[path release], path = nil;
	[mode release], mode = nil;
	[super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<GHBlob sha:'%@'>", sha];
}

#pragma mark Loading

- (void)setValues:(id)theDict {
	self.size = [[theDict valueForKey:@"size"] integerValue];
	self.encoding = [theDict valueForKey:@"encoding"];
	if ([encoding isEqualToString:@"utf-8"]) {
		self.content = [theDict valueForKey:@"content"];
	} else if ([encoding isEqualToString:@"base64"]) {
		NSString *cont = [theDict valueForKey:@"content"];
		self.content = [NSString stringFromBase64String:cont];
		self.contentData = [NSData dataWithBase64String:cont];
	}
}

@end
