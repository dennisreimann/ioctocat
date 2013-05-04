#import "GHResource.h"
#import "GHTree.h"
#import "GHBlob.h"
#import "GHRepository.h"
#import "NSString+Extensions.h"
#import "NSDictionary+Extensions.h"


@implementation GHTree

- (id)initWithRepo:(GHRepository *)repo path:(NSString *)path ref:(NSString*)ref {
	self = [super init];
	if (self) {
		self.repository = repo;
		self.path = path;
		self.ref = ref;
		self.resourcePath = [NSString stringWithFormat:kRepoContentFormat, self.repository.owner, self.repository.name, self.path, self.ref];
	}
	return self;
}

#pragma mark Loading

- (void)setValues:(id)values {
	self.trees = [NSMutableArray array];
	self.blobs = [NSMutableArray array];
    // handle different responses from the tree and repo content APIs
    NSArray *tree = [values isKindOfClass:NSArray.class] ? values : [values safeArrayForKey:@"tree"];
	for (NSDictionary *item in tree) {
		NSInteger size = [item safeIntegerForKey:@"size"];
		NSString *sha  = [item safeStringForKey:@"sha"];
		NSString *type = [item safeStringForKey:@"type"];
		NSString *mode = [item safeStringOrNilForKey:@"mode"];
		NSString *name = [item safeStringOrNilForKey:@"name"];
		NSString *path = [item safeStringOrNilForKey:@"path"];
		if ([type isEqualToString:@"tree"] || [type isEqualToString:@"dir"]) {
			GHTree *obj = [[GHTree alloc] initWithRepo:self.repository path:path ref:self.ref];
			obj.mode = mode;
			[self.trees addObject:obj];
		} else if ([type isEqualToString:@"blob"] || [type isEqualToString:@"file"]) {
			GHBlob *obj = [[GHBlob alloc] initWithRepo:self.repository path:path ref:self.ref];
			obj.mode = mode;
			obj.size = size;
			[self.blobs addObject:obj];
		}
	}
}

@end