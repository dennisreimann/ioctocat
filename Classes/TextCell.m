#import "TextCell.h"
#import "NSString+Extensions.h"


@implementation TextCell

- (void)awakeFromNib {
	maxWidth = contentTextLabel.frame.size.width;
}

- (void)dealloc {
	[contentTextLabel release], contentTextLabel = nil;
    [contentTextView release], contentTextView = nil;
    [super dealloc];
}

- (void)setContentText:(NSString *)theText {
    NSCharacterSet *charSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	theText = [theText stringByTrimmingCharactersInSet:charSet];
    contentTextView.text = theText;
    // Adjust height
    CGRect frame = contentTextView.frame;
    frame.size.height = contentTextView.contentSize.height;
    contentTextView.frame = frame;
}

- (CGFloat)height {
	if (!self.hasContent) return 0;
    return contentTextView.contentSize.height + 10;
}

- (BOOL)hasContent {
    return !(contentTextView.text == nil || [contentTextView.text isEmpty]);
}

@end
