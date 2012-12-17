#import <CommonCrypto/CommonDigest.h>
#import "IOCAvatarLoader.h"
#import "NSURL+Extensions.h"

#define kAvatarMaxLogicalSize 44


@interface IOCAvatarLoader ()
@property(nonatomic,strong)id target;
@property(nonatomic,assign)SEL handle;

- (void)requestWithURL:(NSURL *)url;
@end


@implementation IOCAvatarLoader

+ (id)loaderWithTarget:(id)target andHandle:(SEL)handle {
	return [[self.class alloc] initWithTarget:target andHandle:handle];
}

- (id)initWithTarget:(id)target andHandle:(SEL)handle {
	self = [super init];
	if (self) {
		self.target = target;
		self.handle = handle;
	}
	return self;
}

- (NSInteger)gravatarSize {
	return kAvatarMaxLogicalSize * MAX([UIScreen mainScreen].scale, 1.0);
}

- (void)loadURL:(NSURL *)url {
	NSURL *gravatarURL = [NSURL URLWithFormat:@"%@&s=%d", url, self.gravatarSize];
	[self performSelectorInBackground:@selector(requestWithURL:) withObject:gravatarURL];
}

- (void)requestWithURL:(NSURL *)url {
	@autoreleasepool {
		NSData *gravatarData = [NSData dataWithContentsOfURL:url];
		UIImage *gravatarImage = [UIImage imageWithData:gravatarData];
		if (gravatarImage) [self.target performSelectorOnMainThread:self.handle withObject:gravatarImage waitUntilDone:NO];
	}
}

@end