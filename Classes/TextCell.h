#import <UIKit/UIKit.h>


@interface TextCell : UITableViewCell {
	IBOutlet UITextView *contentTextView;
}

@property(nonatomic,readonly)BOOL hasContent;
@property(nonatomic,readonly)CGFloat height;

- (CGFloat)heightForOuterWidth:(CGFloat)outerWidth;
- (void)setContentText:(NSString *)text;

@end
