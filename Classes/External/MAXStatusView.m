/*
 Copyright (c) 2013 Max Bäumle. All rights reserved.
 */

#import "MAXStatusView.h"

@implementation MAXStatusView

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

#pragma mark Helpers

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillChangeStatusBarFrame:) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
}

#pragma mark Actions

- (void)applicationWillChangeStatusBarFrame:(NSNotification *)notification {
    CGRect statusBarFrame = [[notification userInfo][UIApplicationStatusBarFrameUserInfoKey] CGRectValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect windowFrame = [self.window convertRect:statusBarFrame fromWindow:nil];
        CGRect viewFrame = [self.superview convertRect:windowFrame fromView:nil];
        self.frame = viewFrame;
    });
}

@end