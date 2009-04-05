#import <UIKit/UIKit.h>


@interface LabeledCell : UITableViewCell {
	IBOutlet UILabel *label;
	IBOutlet UILabel *content;
}

@property (nonatomic, readonly) UILabel *label;
@property (nonatomic, readonly) UILabel *content;

@end
