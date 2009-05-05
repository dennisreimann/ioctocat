//
//  FollowingController.h
//  iOctocat
//
//  Created by Mark Lussier on 5/5/09.
//  Copyright 2009 Juniper Networks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHUser.h"
#import "FollowCell.h"

@interface FollowingController : UIViewController {
    GHUser *user;
    @private
	IBOutlet UITableViewCell *loadingFollowingCell;
	IBOutlet UITableViewCell *noFollowingCell;    
    IBOutlet FollowCell *followingCell;

}

@property (nonatomic, retain) GHUser *user;

- (id)initWithUser:(GHUser *)theUser;
- (void)setupFollowing;


@end
