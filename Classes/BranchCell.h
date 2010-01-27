#import <UIKit/UIKit.h>
#import "GHBranch.h"


@interface BranchCell : UITableViewCell {
	GHBranch *branch;
}

@property(nonatomic,retain)GHBranch *branch;

@end
