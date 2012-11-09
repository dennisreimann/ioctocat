#import "GHResource.h"
#import "GHTree.h"
#import "GHBlob.h"
#import "GHRepository.h"
#import "NSString+Extensions.h"


@implementation GHTree

@synthesize sha;
@synthesize repository;
@synthesize trees;
@synthesize blobs;
@synthesize path;
@synthesize mode;

+ (id)treeWithRepo:(GHRepository *)theRepo andSha:(NSString *)theSha {
  return [[[self.class alloc] initWithRepo:theRepo andSha:theSha] autorelease];
}

- (id)initWithRepo:(GHRepository *)theRepo andSha:(NSString *)theSha {
	[super init];
	self.repository = theRepo;
	self.sha = theSha;
	self.resourcePath = [NSString stringWithFormat:kTreeFormat, repository.owner, repository.name, [sha stringByEscapingForURLArgument]];
	return self;
}

- (void)dealloc {
	[repository release], repository = nil;
	[sha release], sha = nil;
	[trees release], trees = nil;
	[blobs release], blobs = nil;
	[path release], path = nil;
	[mode release], mode = nil;
	[super dealloc];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<GHTree sha:'%@'>", sha];
}

#pragma mark Loading

- (void)setValues:(id)theDict {
	self.trees = [NSMutableArray array];
	self.blobs = [NSMutableArray array];
	for (NSDictionary *item in [theDict valueForKey:@"tree"]) {
		NSString *type = [item valueForKey:@"type"];
		NSString *theSha = [item valueForKey:@"sha"];
		NSString *thePath = [item valueForKey:@"path"];
		NSString *theMode = [item valueForKey:@"mode"];
		if ([type isEqualToString:@"tree"]) {
			GHTree *obj = [GHTree treeWithRepo:repository andSha:theSha];
			obj.path = thePath;
			obj.mode = theMode;
			[self.trees addObject:obj];
		} else if ([type isEqualToString:@"blob"]) {
			GHBlob *obj = [GHBlob blobWithRepo:repository andSha:theSha];
			obj.path = thePath;
			obj.mode = theMode;
			obj.size = [[item valueForKey:@"size"] integerValue];
			[self.blobs addObject:obj];
		}
	}
}

@end
