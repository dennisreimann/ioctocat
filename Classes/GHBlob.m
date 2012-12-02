#import "GHResource.h"
#import "GHBlob.h"
#import "GHRepository.h"
#import "NSString+Extensions.h"
#import "MF_Base64Additions.h"


@implementation GHBlob

+ (id)blobWithRepo:(GHRepository *)theRepo andSha:(NSString *)theSha {
  return [[self.class alloc] initWithRepo:theRepo andSha:theSha];
}

- (id)initWithRepo:(GHRepository *)theRepo andSha:(NSString *)theSha {
	self = [super init];
	if (self) {
		self.repository = theRepo;
		self.sha = theSha;
		self.resourcePath = [NSString stringWithFormat:kBlobFormat, self.repository.owner, self.repository.name, [self.sha stringByEscapingForURLArgument]];
	}
	return self;
}

#pragma mark Loading

- (void)setValues:(id)theDict {
	self.size = [[theDict valueForKey:@"size"] integerValue];
	self.encoding = [theDict valueForKey:@"encoding"];
	if ([self.encoding isEqualToString:@"utf-8"]) {
		self.content = [theDict valueForKey:@"content"];
	} else if ([self.encoding isEqualToString:@"base64"]) {
		NSString *cont = [theDict valueForKey:@"content"];
		self.content = [NSString stringFromBase64String:cont];
		self.contentData = [NSData dataWithBase64String:cont];
	}
}

@end
