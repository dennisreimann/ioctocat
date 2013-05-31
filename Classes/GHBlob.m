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
        // prepare to fetch rendered markdown
        __weak __typeof(&*self)weakSelf = self;
        [self whenLoaded:^(GHResource *instance, id data) {
            if (!weakSelf.isMarkdown) return;
            GHResource *resource = [[GHResource alloc] initWithPath:weakSelf.resourcePath];
            resource.resourceContentType = kResourceContentTypeHTML;
            [resource loadWithSuccess:^(GHResource *instance, id data) {
                // the response is not a dictionary, because we requested
                // the html mime type which returns the HTML representation
                weakSelf.contentHTML = [[NSString alloc] initWithData:(NSData *)data encoding:NSUTF8StringEncoding];
            }];
        }];
    }
	return self;
}

- (BOOL)isMarkdown {
    return [self.path hasSuffix:@".md"] || [self.path hasSuffix:@".markdown"];
}

#pragma mark Loading

- (void)setValues:(id)dict {
	self.path = [dict safeStringForKey:@"path"];
	self.size = [dict safeIntegerForKey:@"size"];
    self.htmlURL = [dict safeURLForKey:@"html_url"];
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
