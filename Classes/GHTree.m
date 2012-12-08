#import "GHResource.h"
#import "GHTree.h"
#import "GHBlob.h"
#import "GHRepository.h"
#import "NSString+Extensions.h"


@implementation GHTree

- (id)initWithRepo:(GHRepository *)theRepo andSha:(NSString *)theSha {
	self = [super init];
	if (self) {
		self.repository = theRepo;
		self.sha = theSha;
		self.resourcePath = [NSString stringWithFormat:kTreeFormat, self.repository.owner, self.repository.name, [self.sha stringByEscapingForURLArgument]];
	}
	return self;
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
			GHTree *obj = [[GHTree alloc] initWithRepo:self.repository andSha:theSha];
			obj.path = thePath;
			obj.mode = theMode;
			[self.trees addObject:obj];
		} else if ([type isEqualToString:@"blob"]) {
			GHBlob *obj = [[GHBlob alloc] initWithRepo:self.repository andSha:theSha];
			obj.path = thePath;
			obj.mode = theMode;
			obj.size = [[item valueForKey:@"size"] integerValue];
			[self.blobs addObject:obj];
		}
	}
}

@end