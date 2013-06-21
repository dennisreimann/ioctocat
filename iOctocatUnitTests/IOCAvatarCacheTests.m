#import "IOCAvatarCacheTests.h"
#import "IOCAvatarCache.h"


@interface IOCAvatarCacheTests ()
@property(nonatomic,strong)NSString *gravatarPath;
@property(nonatomic,strong)UIImage *gravatar;
@end


@implementation IOCAvatarCacheTests

- (void)setUp {
    [super setUp];
    [IOCAvatarCache ensureAvatarCacheDirectory];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	self.gravatar = [UIImage imageNamed:@"Icon.png"];
	self.gravatarPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Avatars/gravatar.png"];
}

- (void)tearDown {
    [super tearDown];
    [IOCAvatarCache removeAvatarCacheDirectory];
}

- (void)testGravatarPathForIdentifier {
	expect([IOCAvatarCache gravatarPathForIdentifier:@"gravatar"]).to.equal(self.gravatarPath);
}

- (void)testCacheGravatarForIdentifier {
	[IOCAvatarCache cacheGravatar:self.gravatar forIdentifier:@"gravatar"];
	expect([NSFileManager.defaultManager fileExistsAtPath:self.gravatarPath]).to.beTruthy();
}

- (void)testCachedGravatarForIdentifier {
	[UIImagePNGRepresentation(self.gravatar) writeToFile:self.gravatarPath atomically:YES];
	UIImage *actual = [IOCAvatarCache cachedGravatarForIdentifier:@"gravatar"];
	expect(actual).to.beKindOf(UIImage.class);
}

- (void)testCachedGravatarForIdentifierNoGravatar {
	expect([IOCAvatarCache cachedGravatarForIdentifier:@"gravatar"]).to.beNil();
}

- (void)testClearAvatarCache {
	[UIImagePNGRepresentation(self.gravatar) writeToFile:self.gravatarPath atomically:YES];
	[IOCAvatarCache clearAvatarCache];
	expect([[NSFileManager defaultManager] fileExistsAtPath:self.gravatarPath]).to.beFalsy();
}

@end