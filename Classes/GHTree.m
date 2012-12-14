#import "GHResource.h"
#import "GHTree.h"
#import "GHBlob.h"
#import "GHRepository.h"
#import "NSString+Extensions.h"
#import "NSDictionary+Extensions.h"


@implementation GHTree

- (id)initWithRepo:(GHRepository *)repo andSha:(NSString *)sha {
	self = [super init];
	if (self) {
		self.repository = repo;
		self.sha = sha;
		self.resourcePath = [NSString stringWithFormat:kTreeFormat, self.repository.owner, self.repository.name, [self.sha stringByEscapingForURLArgument]];
	}
	return self;
}

#pragma mark Loading

- (void)setValues:(id)dict {
	self.trees = [NSMutableArray array];
	self.blobs = [NSMutableArray array];
	for (NSDictionary *item in [dict valueForKey:@"tree"]) {
		NSString *type = [item safeStringForKey:@"type"];
		NSString *path = [item safeStringForKey:@"path"];
		NSString *mode = [item safeStringForKey:@"mode"];
		NSString *sha = [item safeStringForKey:@"sha"];
		if ([type isEqualToString:@"tree"]) {
			GHTree *obj = [[GHTree alloc] initWithRepo:self.repository andSha:sha];
			obj.path = path;
			obj.mode = mode;
			[self.trees addObject:obj];
		} else if ([type isEqualToString:@"blob"]) {
			GHBlob *obj = [[GHBlob alloc] initWithRepo:self.repository andSha:sha];
			obj.path = path;
			obj.mode = mode;
			obj.size = [item safeIntegerForKey:@"size"];
			[self.blobs addObject:obj];
		}
	}
}

@end