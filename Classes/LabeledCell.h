#import <UIKit/UIKit.h>


@interface LabeledCell : UITableViewCell
  
@property(nonatomic,strong)IBOutlet UILabel *label;
@property(nonatomic,strong)IBOutlet UILabel *content;
@property(nonatomic,readwrite)BOOL hasContent;

- (void)setLabelText:(NSString *)text;
- (void)setContentText:(NSString *)text;

@end