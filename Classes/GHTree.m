#import "GHResource.h"
#import "GHTree.h"
#import "GHBlob.h"
#import "GHRepository.h"


@implementation GHTree

@synthesize sha;
@synthesize repository;
@synthesize tree;
@synthesize path;
@synthesize mode;

+ (id)treeWithRepo:(GHRepository *)theRepo andSha:(NSString *)theSha {
  return [[[self.class alloc] initWithRepo:theRepo andSha:theSha] autorelease];
}

- (id)initWithRepo:(GHRepository *)theRepo andSha:(NSString *)theSha {
	[super init];
	self.repository = theRepo;
	self.sha = theSha;
	self.resourcePath = [NSString stringWithFormat:kTreeFormat, repository.owner, repository.name, sha];
	return self;
}

- (void)dealloc {
	[repository release], repository = nil;
	[sha release], sha = nil;
	[tree release], tree = nil;
	[path release], path = nil;
	[mode release], mode = nil;
	[super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<GHTree sha:'%@'>", sha];
}

#pragma mark Loading

- (void)setValuesFromDict:(NSDictionary *)theDict {
	self.tree = [NSMutableArray array];
	for (NSDictionary *item in [theDict valueForKey:@"tree"]) {
		NSString *type = [item valueForKey:@"type"];
		NSString *theSha = [item valueForKey:@"sha"];
		NSString *thePath = [item valueForKey:@"path"];
		NSString *theMode = [item valueForKey:@"mode"];
		if ([type isEqualToString:@"tree"]) {
			GHTree *obj = [GHTree treeWithRepo:repository andSha:theSha];
			obj.path = thePath;
			obj.mode = theMode;
			[self.tree addObject:obj];
		} else if ([type isEqualToString:@"blob"]) {
			GHBlob *obj = [GHBlob blobWithRepo:repository andSha:theSha];
			obj.path = thePath;
			obj.mode = theMode;
			obj.size = [[item valueForKey:@"size"] integerValue];
			[self.tree addObject:obj];
		}
	}
}

@end
