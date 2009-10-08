#import "TextCell.h"


@implementation TextCell

- (void)dealloc {
	[contentTextLabel release];
    [super dealloc];
}

- (void)setContentText:(NSString *)theText {
	contentTextLabel.text = theText;
	[contentTextLabel sizeToFit];
	CGFloat maxWidth = 275;
	if (contentTextLabel.frame.size.width > maxWidth) {
		contentTextLabel.frame = CGRectMake(contentTextLabel.frame.origin.x, contentTextLabel.frame.origin.y, maxWidth, self.height);
	}
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

@end
