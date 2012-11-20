#import <UIKit/UIKit.h>


@interface TextCell : UITableViewCell {
	IBOutlet UITextView *contentTextView;
}

@property(nonatomic,readonly)BOOL hasContent;
@property(nonatomic,readonly)CGFloat height;

- (CGFloat)heightForTableView:(UITableView *)tableView;
- (void)setContentText:(NSString *)text;

@end