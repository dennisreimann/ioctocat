/*
 Copyright (c) 2013 Max Bäumle. All rights reserved.
 */

#import "MAXStatusWindow.h"

@implementation MAXStatusWindow

- (id)init {
    self = [super init];
    if (self) {
        [self addObserver];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addObserver];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
}

#pragma mark View Events

//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
//    if ([super pointInside:point withEvent:event]) {
//        [self performSelector:@selector(checkGitHubSystemStatus) withObject:nil afterDelay:0.1];
//    }
//    return NO;
//}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

#pragma mark Helpers

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillChangeStatusBarFrame:) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
}

#pragma mark Actions

- (void)applicationWillChangeStatusBarFrame:(NSNotification *)notification {
    self.frame = [[notification userInfo][UIApplicationStatusBarFrameUserInfoKey] CGRectValue];
}

//- (void)checkGitHubSystemStatus {
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkGitHubSystemStatus) object:nil];
//    [[iOctocat sharedInstance] checkGitHubSystemStatus];
//}

@end