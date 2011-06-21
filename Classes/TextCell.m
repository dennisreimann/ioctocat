#import "TextCell.h"
#import "NSString+Extensions.h"


@implementation TextCell

- (void)awakeFromNib {
	maxWidth = contentTextLabel.frame.size.width;
    paddingY = 10;
}

- (void)dealloc {
	[contentTextLabel release], contentTextLabel = nil;
    [contentTextView release], contentTextView = nil;
    [super dealloc];
}

- (void)adjustTextView {
    CGRect frame = contentTextView.frame;
    // contentTextView.contentSize.height should be just right, but sometimes
    // the last line gets ignored if it contains just one word, so we add 20
    frame.size.height = contentTextView.contentSize.height + 20;
    contentTextView.frame = frame;
}

- (void)setContentText:(NSString *)theText {
    contentTextView.text = theText;
    [self adjustTextView];
}

- (CGFloat)height {
	if (!self.hasContent) return 0;
    return contentTextView.frame.size.height + paddingY;
}

- (BOOL)hasContent {
    return !(contentTextView.text == nil || [contentTextView.text isEmpty]);
}

@end
