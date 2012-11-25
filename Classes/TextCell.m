#import "TextCell.h"
#import "NSString+Extensions.h"


@interface TextCell ()
- (CGFloat)marginTop;
- (CGFloat)marginRight;
- (CGFloat)marginBottom;
- (CGFloat)marginLeft;
- (void)adjustTextViewHeight;
@end

@implementation TextCell

- (void)dealloc {
	[contentTextView release], contentTextView = nil;
	[super dealloc];
}

- (void)setContentText:(NSString *)theText {
	contentTextView.text = theText;
	[self adjustTextViewHeight];
}

- (BOOL)hasContent {
	return !(contentTextView.text == nil || [contentTextView.text isEmpty]);
}

- (void)adjustTextViewHeight {
	CGRect frame = contentTextView.frame;
	frame.size.height = self.hasContent ? contentTextView.contentSize.height + self.textInset : 0.0f;
	contentTextView.frame = frame;
}

#pragma mark Layout

- (CGFloat)textInset {
	return 8.0f; // UITextView has an inset of 8px on each side
}

- (CGFloat)marginTop {
	return 0.0f;
}

- (CGFloat)marginRight {
	return 5.0f;
}

- (CGFloat)marginBottom {
	return 0.0f;
}

- (CGFloat)marginLeft {
	return 5.0f;
}

- (CGFloat)heightForTableView:(UITableView *)tableView {
	if (!self.hasContent) return 0;
	// calculate the outer width of the cell based on the tableView style
	CGFloat outerWidth = tableView.frame.size.width;
	if (tableView.style == UITableViewStyleGrouped) {
		// on the iPhone the inset is 20px, on the iPad 90px
		outerWidth -= [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone ? 20.0f : 90.0f;
	}
	CGFloat maxHeight = 50000.0f;
	CGFloat textInset = self.textInset * 2;
	CGFloat marginH  = self.marginLeft + self.marginRight;
	CGFloat marginV  = self.marginTop + self.marginBottom;
	CGFloat width = outerWidth - marginH;
	CGFloat textWidth = width - textInset;
	CGSize constraint = CGSizeMake(textWidth, maxHeight);
	CGSize size = [contentTextView.text sizeWithFont:contentTextView.font
	constrainedToSize:constraint
	lineBreakMode:UILineBreakModeWordWrap];
	CGFloat height = size.height + textInset + marginV;
	return height;
}

@end