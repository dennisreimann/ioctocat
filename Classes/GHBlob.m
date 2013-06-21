#import "GHResource.h"
#import "GHBlob.h"
#import "GHRepository.h"
#import "NSString_IOCExtensions.h"
#import "NSDictionary_IOCExtensions.h"
#import "MF_Base64Additions.h"
#import "AFHTTPRequestOperation.h"


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

- (BOOL)isMarkdown {
    return [self.path hasSuffix:@".md"] || [self.path hasSuffix:@".markdown"];
}

- (loadSuccess)onLoadSuccess {
    return ^(AFHTTPRequestOperation *operation, id data) {
        if ([data isKindOfClass:NSDictionary.class]) {
            self.path = [data ioc_stringForKey:@"path"];
        }
        if (self.isMarkdown) {
            // set initial data without marking as loaded
            // and running the success blocks
            NSDictionary *headers = operation.response.allHeaderFields;
            D3JLog(@"\n%@: Loading %@ finished.\n\nHeaders:\n%@\n\nData:\n%@\n", self.class, operation.response.URL, headers, data);
            [self setHeaderValues:headers];
            [self setValues:data];
            // then fetch rendered markdown
            GHResource *resource = [[GHResource alloc] initWithPath:self.resourcePath];
            resource.resourceContentType = kResourceContentTypeHTML;
            [resource loadWithSuccess:^(GHResource *instance, id data) {
                super.onLoadSuccess(operation, data);
            }];
        } else {
            super.onLoadSuccess(operation, data);
        }
	};
}

#pragma mark Loading

- (void)setValues:(id)response {
    if ([response isKindOfClass:NSDictionary.class]) {
        self.path = [response ioc_stringForKey:@"path"];
        self.size = [response ioc_integerForKey:@"size"];
        self.htmlURL = [response ioc_URLForKey:@"html_url"];
        self.encoding = [response ioc_stringForKey:@"encoding"];
        if ([self.encoding isEqualToString:@"utf-8"]) {
            self.content = [response ioc_stringForKey:@"content"];
        } else if ([self.encoding isEqualToString:@"base64"]) {
            NSString *cont = [response ioc_stringForKey:@"content"];
            self.content = [NSString stringFromBase64String:cont];
            self.contentData = [NSData dataWithBase64String:cont];
        }
    } else if ([response isKindOfClass:NSData.class]) {
        // the response is not a dictionary, because we requested
        // the html mime type which returns the HTML representation
        self.contentHTML = [[NSString alloc] initWithData:(NSData *)response encoding:NSUTF8StringEncoding];
    }
}

@end
