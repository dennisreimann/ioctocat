#import "TextCell.h"
#import "NSString+Extensions.h"


@interface TextCell ()
@property(nonatomic,weak)IBOutlet UITextView *contentTextView;

- (void)adjustTextViewHeight;
- (CGFloat)textInset;
- (CGFloat)marginTop;
- (CGFloat)marginRight;
- (CGFloat)marginBottom;
- (CGFloat)marginLeft;
@end


@implementation TextCell

- (void)setContentText:(NSString *)theText {
	self.contentTextView.text = theText;
	[self adjustTextViewHeight];
}

- (BOOL)hasContent {
	return !(self.contentTextView.text == nil || [self.contentTextView.text isEmpty]);
}

- (void)adjustTextViewHeight {
	CGRect frame = self.contentTextView.frame;
	frame.size.height = self.hasContent ? self.contentTextView.contentSize.height + self.textInset : 0.0f;
	self.contentTextView.frame = frame;
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

- (CGFloat)textWidthForOuterWidth:(CGFloat)outerWidth {
	CGFloat textInset = self.textInset * 2;
	CGFloat marginH  = self.marginLeft + self.marginRight;
	CGFloat width = outerWidth - marginH;
	CGFloat textWidth = width - textInset;
	return textWidth;
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
	CGFloat marginV  = self.marginTop + self.marginBottom;
	CGFloat textWidth = [self textWidthForOuterWidth:outerWidth];
	CGSize constraint = CGSizeMake(textWidth, maxHeight);
	CGSize size = [self.contentTextView.text sizeWithFont:self.contentTextView.font
	constrainedToSize:constraint
	lineBreakMode:UILineBreakModeWordWrap];
	CGFloat height = size.height + textInset + marginV;
	return height;
}

@end