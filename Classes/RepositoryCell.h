#import <UIKit/UIKit.h>
#import "GHRepository.h"


@interface RepositoryCell : UITableViewCell {
	GHRepository *repository;
}

@property (nonatomic, retain) GHRepository *repository;

@end
