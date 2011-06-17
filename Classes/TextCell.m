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
//    contentTextView.text = theText;
    // Adjust height
//    CGRect frame = contentTextView.frame;
//    frame.size.height = contentTextView.contentSize.height - 20;
//    contentTextView.frame = frame;
    
    
    CGSize textSize = { contentTextView.contentSize.width, 9999.0f };
    CGSize size = [theText sizeWithFont:contentTextView.font constrainedToSize:textSize lineBreakMode:UILineBreakModeWordWrap];
    contentTextView.text = theText;
    CGRect frame = contentTextView.frame;
    frame.size.height = size.height; //contentTextView.contentSize.height - 20;
    contentTextView.frame = frame;
}

- (CGFloat)height {
	if (!self.hasContent) return 0;
    return contentTextView.frame.size.height + 10;
}

- (BOOL)hasContent {
    return !(contentTextView.text == nil || [contentTextView.text isEmpty]);
}

@end
