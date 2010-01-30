#import <UIKit/UIKit.h>


@interface LabeledCell : UITableViewCell {
  @private
	IBOutlet UILabel *label;
	IBOutlet UILabel *content;
	BOOL hasContent;
}

@property(nonatomic,readonly)BOOL hasContent;

- (void)setLabelText:(NSString *)text;
- (void)setContentText:(NSString *)text;

@end
