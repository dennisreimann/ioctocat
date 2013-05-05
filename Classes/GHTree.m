#import "GHResource.h"
#import "GHTree.h"
#import "GHBlob.h"
#import "GHSubmodule.h"
#import "GHRepository.h"
#import "NSURL+Extensions.h"
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

- (NSString *)shortenedSha {
    return [self.sha substringToIndex:7];
}

#pragma mark Loading

- (void)setValues:(id)values {
	self.trees = [NSMutableArray array];
	self.blobs = [NSMutableArray array];
	self.submodules = [NSMutableArray array];
    // handle different responses from the tree and repo content APIs
    NSArray *tree = [values isKindOfClass:NSArray.class] ? values : [values safeArrayForKey:@"tree"];
	for (NSDictionary *item in tree) {
		NSInteger size = [item safeIntegerForKey:@"size"];
		NSString *sha  = [item safeStringForKey:@"sha"];
		NSString *type = [item safeStringForKey:@"type"];
		NSString *mode = [item safeStringOrNilForKey:@"mode"];
		NSString *name = [item safeStringOrNilForKey:@"name"];
		NSString *path = [item safeStringOrNilForKey:@"path"];
        // eventually correct the type: workaround for a limitation in the GitHub API v3, see
        // https://github.com/github/developer.github.com/commit/1b329b04cece9f3087faa7b1e0382317a9b93490
        GHRepository *submoduleRepo = nil;
        if ([type isEqualToString:@"submodule"] || ([type isEqualToString:@"file"] && size == 0)) {
            NSURL *gitURL = [NSURL smartURLFromString:[item safeStringOrNilForKey:@"git_url"]];
            NSArray *comps = [gitURL pathComponents];
            if (comps.count > 3) {
                NSString *submoduleOwner = [comps objectAtIndex:2];
                NSString *submoduleName = [comps objectAtIndex:3];
                submoduleRepo = [[GHRepository alloc] initWithOwner:submoduleOwner andName:submoduleName];
                type = @"submodule";
            }
        }
        // distinguish types
		if ([type isEqualToString:@"dir"]) {
			GHTree *obj = [[GHTree alloc] initWithRepo:self.repository path:path ref:self.ref];
			obj.mode = mode;
			[self.trees addObject:obj];
		} else if ([type isEqualToString:@"file"]) {
			GHBlob *obj = [[GHBlob alloc] initWithRepo:self.repository path:path ref:self.ref];
			obj.mode = mode;
			obj.size = size;
			[self.blobs addObject:obj];
		} else if ([type isEqualToString:@"submodule"] && submoduleRepo) {
			GHSubmodule *obj = [[GHSubmodule alloc] initWithRepo:submoduleRepo path:path sha:sha];
			obj.name = name;
			[self.submodules addObject:obj];
		} else if ([type isEqualToString:@"symlink"]) {
			// TODO
		}
	}
}

@end