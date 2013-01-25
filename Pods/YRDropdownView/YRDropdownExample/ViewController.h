//
//  ViewController.h
//  YRDropdownExample
//
//  Created by Eli Perkins on 1/27/12.
//  Copyright (c) 2012 One Mighty Roar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIView *demoView;
- (IBAction)showInView:(id)sender;
- (IBAction)showInWindow:(id)sender;
- (IBAction)hide:(id)sender;

@end
