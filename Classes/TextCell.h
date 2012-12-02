#import <UIKit/UIKit.h>


@interface TextCell : UITableViewCell

@property(nonatomic,readonly)BOOL hasContent;
@property(nonatomic,readonly)CGFloat height;
@property(nonatomic,weak)IBOutlet UITextView *contentTextView;

- (CGFloat)textInset;
- (CGFloat)heightForTableView:(UITableView *)tableView;
- (CGFloat)textWidthForOuterWidth:(CGFloat)outerWidth;
- (void)setContentText:(NSString *)text;
- (void)adjustTextViewHeight;

@end