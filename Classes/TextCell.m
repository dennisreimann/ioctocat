#import "TextCell.h"
#import "NSString+Extensions.h"


@implementation TextCell

- (void)awakeFromNib {
	maxWidth = contentTextLabel.frame.size.width;
}

- (void)dealloc {
	[contentTextLabel release];
    [super dealloc];
}

- (void)setContentText:(NSString *)theText {
	contentTextLabel.text = theText;
	CGSize constraint = CGSizeMake(maxWidth, 20000);
	CGSize size = [theText sizeWithFont:contentTextLabel.font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
	contentTextLabel.frame = CGRectMake(contentTextLabel.frame.origin.x, contentTextLabel.frame.origin.y, maxWidth, size.height);
}

- (CGFloat)height {
	if (!self.hasContent) return 0;
	CGFloat height = contentTextLabel.frame.size.height + 20; // 20 is the vertical margin
	return height;
}

- (BOOL)hasContent {
	return !(contentTextLabel.text == nil || [contentTextLabel.text isEmpty]);
}

@end
