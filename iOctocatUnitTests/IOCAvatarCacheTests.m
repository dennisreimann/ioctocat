#import "IOCAvatarCacheTests.h"
#import "IOCAvatarCache.h"


@interface IOCAvatarCacheTests ()
@property(nonatomic,strong)NSString *gravatarPath;
@property(nonatomic,strong)UIImage *gravatar;
@end


@implementation IOCAvatarCacheTests

- (void)setUp {
    [super setUp];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	self.gravatar = [UIImage imageNamed:@"Icon.png"];
	self.gravatarPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"gravatar.png"];
}

- (void)tearDown {
    [super tearDown];
	[[NSFileManager defaultManager] removeItemAtPath:self.gravatarPath error:NULL];
}

- (void)testGravatarPathForIdentifier {
	NSString *actual = [IOCAvatarCache gravatarPathForIdentifier:@"gravatar"];
	STAssertEqualObjects(self.gravatarPath, actual, @"Paths do not match");
}

- (void)testCacheGravatarForIdentifier {
	[IOCAvatarCache cacheGravatar:self.gravatar forIdentifier:@"gravatar"];
	STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:self.gravatarPath], @"Gravatar was not written to documents directory");
}

- (void)testCachedGravatarForIdentifier {
	[UIImagePNGRepresentation(self.gravatar) writeToFile:self.gravatarPath atomically:YES];
	UIImage *actual = [IOCAvatarCache cachedGravatarForIdentifier:@"gravatar"];
	STAssertEquals([UIImage class], actual.class, @"Gravatar was not returned as an UIImage instance");
}

- (void)testCachedGravatarForIdentifierNoGravatar {
	UIImage *actual = [IOCAvatarCache cachedGravatarForIdentifier:@"gravatar"];
	STAssertNil(actual, @"Gravatar was found even though it should not exist");
}

- (void)testClearAvatarCache {
	[UIImagePNGRepresentation(self.gravatar) writeToFile:self.gravatarPath atomically:YES];
	[IOCAvatarCache clearAvatarCache];
	STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:self.gravatarPath], @"Gravatar did not get removed from documents directory");
}

@end