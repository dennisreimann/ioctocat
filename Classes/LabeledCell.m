#import "LabeledCell.h"
#import "NSString+Extensions.h"


@interface LabeledCell ()
@property(nonatomic,assign)BOOL hasContent;
@property(nonatomic,weak)IBOutlet UILabel *label;
@property(nonatomic,weak)IBOutlet UILabel *content;
@end


@implementation LabeledCell

- (void)setLabelText:(NSString *)text {
	self.label.text = text;
}

- (void)setContentText:(NSString *)text {
	self.hasContent = (![text isKindOfClass:[NSNull class]] && text != nil && ![text isEmpty]);
	self.content.text = self.hasContent ? text : @"n/a";
	self.content.textColor = self.hasContent ? [UIColor blackColor] : [UIColor grayColor];
	self.content.highlightedTextColor = [UIColor whiteColor];
}

@end