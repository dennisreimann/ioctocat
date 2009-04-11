#import "TextCell.h"


@implementation TextCell

- (void)setContentText:(NSString *)text {
	contentTextLabel.text = text;
	[contentTextLabel sizeToFit];
}

- (CGFloat)height {
	CGFloat verticalMargin = contentTextLabel.frame.origin.y * 2;
	CGFloat height = contentTextLabel.frame.size.height + verticalMargin;
	return height;
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[contentTextLabel release];
    [super dealloc];
}

@end
