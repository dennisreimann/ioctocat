//
//  UIViewController_IOCExtensions.m
//  iOctocat
//
//  Created by Dennis Reimann on 06/20/13.
//  http://dennisreimann.de
//

#import "UIViewController_IOCExtensions.h"


@implementation UIViewController (IOCExtensions)

- (BOOL)ioc_isBeingPopped {
    if (!self.navigationController) return NO;
    NSArray *viewControllers = self.navigationController.viewControllers;
    return [viewControllers indexOfObject:self] == NSNotFound;
}

@end