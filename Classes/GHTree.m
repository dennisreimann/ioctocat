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
		self.resourcePath = [NSString stringWithFormat:kRepoContentFormat, self.repository.owner, self.repository.name, self.path, ref];
	}
	return self;
}

- (id)initWithRepo:(GHRepository *)repo sha:(NSString *)sha {
	self = [super init];
	if (self) {
		self.repository = repo;
		self.sha = sha;
		self.resourcePath = [NSString stringWithFormat:kTreeFormat, self.repository.owner, self.repository.name, [self.sha stringByEscapingForURLArgument]];
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
		NSString *sha = [item safeStringForKey:@"sha"];
		NSString *type = [item safeStringForKey:@"type"];
		NSString *mode = [item safeStringOrNilForKey:@"mode"];
		NSString *name = [item safeStringOrNilForKey:@"name"];
		if (!name) name = [item safeStringForKey:@"path"];
		if ([type isEqualToString:@"tree"] || [type isEqualToString:@"dir"]) {
			GHTree *obj = [[GHTree alloc] initWithRepo:self.repository sha:sha];
			obj.path = name;
			obj.mode = mode;
			[self.trees addObject:obj];
		} else if ([type isEqualToString:@"blob"] || [type isEqualToString:@"file"]) {
			GHBlob *obj = [[GHBlob alloc] initWithRepo:self.repository sha:sha];
			obj.path = name;
			obj.mode = mode;
			obj.size = [item safeIntegerForKey:@"size"];
			[self.blobs addObject:obj];
		}
	}
}

@end