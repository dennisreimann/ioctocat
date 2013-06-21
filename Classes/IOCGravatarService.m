#import "IOCGravatarService.h"
#import "NSURL_IOCExtensions.h"

#define kAvatarMaxLogicalSize 50
#define kDisableAvatarLoadingKey @"disableAvatarLoading"


@implementation IOCGravatarService

+ (void)loadWithURL:(NSURL *)url success:(void (^)(UIImage *))success failure:(void (^)())failure {
    BOOL disableAvatarLoading = [[NSUserDefaults standardUserDefaults] boolForKey:kDisableAvatarLoadingKey];
    if (disableAvatarLoading) return;
    NSInteger gravatarSize = kAvatarMaxLogicalSize * MAX([UIScreen mainScreen].scale, 1.0);
    NSURL *gravatarURL = [NSURL ioc_URLWithFormat:@"%@&s=%d", url, gravatarSize];
    dispatch_queue_t currentBackgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(currentBackgroundQueue, ^{
        NSData *data = [NSData dataWithContentsOfURL:gravatarURL];
        UIImage *image = [UIImage imageWithData:data];
        if (image) {
            if (!success) return;
            dispatch_async(dispatch_get_main_queue(), ^{
                success(image);
            });
        } else {
            if (failure) failure();
        }
    });
}

@end