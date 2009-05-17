#import <UIKit/UIKit.h>
#import "GHNetwork.h"


@interface NetworkCell : UITableViewCell {
	GHNetwork *network;
  @private 
    IBOutlet UILabel *name;
    IBOutlet UILabel *userName;
  	IBOutlet UIImageView *iconView;
}

@property (nonatomic, retain) GHNetwork *network;

@end

