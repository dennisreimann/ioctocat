#import "TextCell.h"
#import "NSString+Extensions.h"


@interface TextCell ()
- (CGFloat)paddingHorizontal;
- (CGFloat)paddingVertical;
@end

@implementation TextCell

- (void)dealloc {
    [contentTextView release], contentTextView = nil;
    [super dealloc];
}

- (void)adjustTextViewHeight {
	CGRect frame = contentTextView.frame;
    frame.size.height = contentTextView.contentSize.height;
    contentTextView.frame = frame;
}

- (void)setContentText:(NSString *)theText {
    contentTextView.text = theText;
	[self adjustTextViewHeight];
}

- (CGFloat)paddingHorizontal {
	return 5.0f;
}

- (CGFloat)paddingVertical {
	return 2.0f;
}

- (CGFloat)heightForOuterWidth:(CGFloat)outerWidth {
	if (!self.hasContent) return 0;
	CGFloat width = outerWidth - 20.0f;
	CGFloat maxHeight = 50000.0f;
	CGFloat textViewPadding = 16.0f; // contentTextView has an inset of 8px on each side
	CGFloat paddingH  = self.paddingHorizontal * 2;
	CGFloat paddingV  = self.paddingVertical * 2;
	CGFloat textWidth = width - textViewPadding - paddingH;
	CGSize constraint = CGSizeMake(textWidth, maxHeight);
	CGSize size = [contentTextView.text sizeWithFont:contentTextView.font
								   constrainedToSize:constraint
									   lineBreakMode:UILineBreakModeWordWrap];
	CGFloat height = size.height + paddingV + textViewPadding;

	DJLog(@"o width: %f\nwidth:   %f\no height: %f\nheight:   %f", width, textWidth, size.height, height);
	return height;
}

- (BOOL)hasContent {
    return !(contentTextView.text == nil || [contentTextView.text isEmpty]);
}

@end
