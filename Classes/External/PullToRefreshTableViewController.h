//
//  PullToRefreshTableViewController.h
//  ASiST
//
//  Created by Oliver on 09.12.09.
//  Copyright 2009 Drobnik.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGORefreshTableHeaderView.h"
#import "SoundEffect.h"

@interface PullToRefreshTableViewController : UITableViewController 
{
	EGORefreshTableHeaderView *refreshHeaderView;
	BOOL checkForRefresh;
	BOOL reloading;
}

- (void)dataSourceDidFinishLoadingNewData;
- (void) showReloadAnimationAnimated:(BOOL)animated;

@end