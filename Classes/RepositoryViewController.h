#import <UIKit/UIKit.h>


@class GHRepository;

@interface RepositoryViewController : UITableViewController {
  @private
	GHRepository *repository;
	IBOutlet UIView *tableHeaderView;
	IBOutlet UILabel *nameLabel;
	IBOutlet UILabel *numbersLabel;
	IBOutlet UIActivityIndicatorView *activityView;
}

- (id)initWithRepository:(GHRepository *)theRepository;

@end
