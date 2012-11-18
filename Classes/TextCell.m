#import "TextCell.h"
#import "NSString+Extensions.h"


@interface TextCell ()
- (CGFloat)marginTop;
- (CGFloat)marginRight;
- (CGFloat)marginBottom;
- (CGFloat)marginLeft;
@end

@implementation TextCell

- (void)dealloc {
    [contentTextView release], contentTextView = nil;
    [super dealloc];
}

- (void)setContentText:(NSString *)theText {
    contentTextView.text = theText;
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
	CGFloat textInset = 16.0f;
	CGFloat marginH  = self.marginLeft + self.marginRight;
	CGFloat marginV  = self.marginTop + self.marginBottom;
	// calculate the text width: UITextView has an inset of 8px on each side
	CGFloat width = outerWidth - marginH;
	CGFloat textWidth = width - textInset;
	CGSize constraint = CGSizeMake(textWidth, maxHeight);
	CGSize size = [contentTextView.text sizeWithFont:contentTextView.font
								   constrainedToSize:constraint
									   lineBreakMode:UILineBreakModeWordWrap];
	CGFloat height = size.height + textInset + marginV;
	return height;
}

- (BOOL)hasContent {
    return !(contentTextView.text == nil || [contentTextView.text isEmpty]);
}

@end
