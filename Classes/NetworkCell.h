#import <UIKit/UIKit.h>
#import "GHRepository.h"


@interface NetworkCell : UITableViewCell {
	GHRepository *repository;
  @private 
    IBOutlet UILabel *name;
    IBOutlet UILabel *userName;
  	IBOutlet UIImageView *iconView;
}

@property(nonatomic,retain)GHRepository *repository;

@end

