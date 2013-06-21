#import "GHResource.h"
#import "GHTree.h"
#import "GHBlob.h"
#import "GHSubmodule.h"
#import "GHRepository.h"
#import "NSURL_IOCExtensions.h"
#import "NSString_IOCExtensions.h"
#import "NSDictionary_IOCExtensions.h"


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
    NSArray *tree = [values isKindOfClass:NSArray.class] ? values : [values ioc_arrayForKey:@"tree"];
	for (NSDictionary *item in tree) {
		NSInteger size = [item ioc_integerForKey:@"size"];
		NSString *sha  = [item ioc_stringForKey:@"sha"];
		NSString *type = [item ioc_stringForKey:@"type"];
		NSString *mode = [item ioc_stringOrNilForKey:@"mode"];
		NSString *name = [item ioc_stringOrNilForKey:@"name"];
		NSString *path = [item ioc_stringOrNilForKey:@"path"];
        // eventually correct the type: workaround for a limitation in the GitHub API v3, see
        // https://github.com/github/developer.github.com/commit/1b329b04cece9f3087faa7b1e0382317a9b93490
        GHRepository *submoduleRepo = nil;
        if ([type isEqualToString:@"submodule"] || ([type isEqualToString:@"file"] && size == 0)) {
            NSURL *gitURL = [NSURL ioc_smartURLFromString:[item ioc_stringOrNilForKey:@"git_url"]];
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