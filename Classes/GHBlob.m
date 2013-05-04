#import "GHResource.h"
#import "GHBlob.h"
#import "GHRepository.h"
#import "NSString+Extensions.h"
#import "NSDictionary+Extensions.h"
#import "MF_Base64Additions.h"


@implementation GHBlob

- (id)initWithRepo:(GHRepository *)repo path:(NSString *)path ref:(NSString*)ref {
	self = [super init];
	if (self) {
		self.repository = repo;
		self.path = path;
		self.resourcePath = [NSString stringWithFormat:kRepoContentFormat, self.repository.owner, self.repository.name, self.path, ref];
	}
	return self;
}

#pragma mark Loading

- (void)setValues:(id)dict {
	self.size = [dict safeIntegerForKey:@"size"];
	self.encoding = [dict safeStringForKey:@"encoding"];
	if ([self.encoding isEqualToString:@"utf-8"]) {
		self.content = [dict safeStringForKey:@"content"];
	} else if ([self.encoding isEqualToString:@"base64"]) {
		NSString *cont = [dict safeStringForKey:@"content"];
		self.content = [NSString stringFromBase64String:cont];
		self.contentData = [NSData dataWithBase64String:cont];
	}
}

@end
