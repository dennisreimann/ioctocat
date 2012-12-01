#import "LabeledCell.h"
#import "NSString+Extensions.h"


@implementation LabeledCell

- (void)dealloc {
	[_label release], _label = nil;
	[_content release], _content = nil;
	[super dealloc];
}

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