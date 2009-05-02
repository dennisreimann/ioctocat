#import "TextCell.h"


@implementation TextCell

- (void)setContentText:(NSString *)text {
	contentTextLabel.text = text;
	[contentTextLabel sizeToFit];
}

- (CGFloat)height {
	if (!self.hasContent) return 0;
	CGFloat verticalMargin = contentTextLabel.frame.origin.y * 2;
	CGFloat height = contentTextLabel.frame.size.height + verticalMargin;
	return height;
}

- (BOOL)hasContent {
	return !(contentTextLabel.text == nil || [contentTextLabel.text isEqualToString:@""]);
}

- (void)dealloc {
	[contentTextLabel release];
    [super dealloc];
}

@end
