#import "IOCTextCell.h"
#import "NSString+Emojize.h"
#import "NSString+Extensions.h"
#import "NSString+GHFMarkdown.h"
#import "NSAttributedString+GHFMarkdown.h"
#import "TTTAttributedLabel.h"


@interface IOCTextCell ()
@property(nonatomic,weak)IBOutlet TTTAttributedLabel *contentLabel;
@end


@implementation IOCTextCell

- (void)awakeFromNib {
    [super awakeFromNib];
    UIColor *linkColor = [UIColor colorWithRed:0.203 green:0.441 blue:0.768 alpha:1.000];
    self.linksEnabled = YES;
    self.emojiEnabled = YES;
    self.markdownEnabled = YES;
    self.truncationLength = 0;
	self.contentLabel.numberOfLines = 0;
    self.contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.contentLabel.delegate = self;
    self.contentLabel.linkAttributes = [NSDictionary dictionaryWithObjects:@[@NO, (id)[linkColor CGColor]] forKeys:@[(NSString *)kCTUnderlineStyleAttributeName, (NSString *)kCTForegroundColorAttributeName]];
    self.contentLabel.activeLinkAttributes = [NSDictionary dictionaryWithObjects:@[@YES, (id)[linkColor CGColor]] forKeys:@[(NSString *)kCTUnderlineStyleAttributeName, (NSString *)kCTForegroundColorAttributeName]];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	[self adjustContentTextHeight];
}

- (void)setLinksEnabled:(BOOL)linksEnabled {
    _linksEnabled = linksEnabled;
    self.contentLabel.dataDetectorTypes = linksEnabled ? UIDataDetectorTypeLink : UIDataDetectorTypeNone;
}

- (void)setContentText:(NSString *)text {
    if ([self.contentText isEqualToString:text]) return;
    _contentText = text;
    // return on nil
    if (!_contentText) {
        self.contentLabel.text = nil;
        return;
    }
    // parse and modify label text
    if (self.emojiEnabled) text = [text emojizedString];
    if (self.truncationLength && text.length > self.truncationLength) {
        NSRange range = {0, self.truncationLength};
        text = [NSString stringWithFormat:@"%@…", [text substringWithRange:range]];
    }
    if (self.markdownEnabled) {
        self.contentLabel.text = [NSAttributedString attributedStringFromMarkdown:text attributes:self.defaultAttributes];
        NSArray *links = [text linksFromGHFMarkdownWithContextRepoId:self.contextRepoId];
        for (NSDictionary *link in [links reverseObjectEnumerator]) {
            NSRange range = [self.contentLabel.text rangeOfString:link[@"title"]];
            [self.contentLabel addLinkToURL:link[@"url"] withRange:range];
        }
    } else {
        self.contentLabel.text = text;
    }
    [self adjustContentTextHeight];
}

- (BOOL)hasContent {
	return self.contentLabel.text != nil && ![self.contentLabel.text isEmpty];
}

#pragma mark Actions

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if ([self.delegate respondsToSelector:@selector(openURL:)] && url) {
        [self.delegate openURL:url];
    }
}

- (void)copy:(id)sender {
    [UIPasteboard generalPasteboard].string = self.contentText;
}

#pragma mark Layout

- (CGFloat)heightWithoutContentText {
	return 0.0f;
}

- (CGFloat)contentTextMarginTop {
	return 10.0f;
}

- (CGFloat)contentTextMarginRight {
	return 10.0f;
}

- (CGFloat)contentTextMarginBottom {
	return 10.0f;
}

- (CGFloat)contentTextMarginLeft {
	return 10.0f;
}

- (void)adjustContentTextHeight {
	CGRect frame = self.contentLabel.frame;
	frame.size.height = [self contentTextHeightForWidth:frame.size.width];
	self.contentLabel.frame = frame;
}

- (CGFloat)contentTextHeightForWidth:(CGFloat)width {
    CGSize constraint = CGSizeMake(width, CGFLOAT_MAX);
    CGSize size = [self.contentLabel sizeThatFits:constraint];
    return size.height;
}

- (CGFloat)heightForTableView:(UITableView *)tableView {
    if (!self.hasContent) return self.heightWithoutContentText;
    // calculate the outer width of the cell based on the tableView style
	CGFloat width = tableView.frame.size.width;
	if (tableView.style == UITableViewStyleGrouped) {
		// on the iPhone the inset is 20px, on the iPad 90px
		width -= [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone ? 20.0f : 90.0f;
	}
    CGFloat marginH = self.contentTextMarginLeft + self.contentTextMarginRight;
	CGFloat marginV = self.contentTextMarginTop + self.contentTextMarginBottom;
    width -= marginH;
	CGFloat contentTextHeight = [self contentTextHeightForWidth:width];
	return self.heightWithoutContentText + contentTextHeight + marginV;
}

- (NSMutableDictionary *)defaultAttributes {
    TTTAttributedLabel *label = self.contentLabel;
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    if (NSMutableParagraphStyle.class) {
        [attrs setObject:label.font forKey:(NSString *)kCTFontAttributeName];
        [attrs setObject:label.textColor forKey:(NSString *)kCTForegroundColorAttributeName];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.alignment = label.textAlignment;
        style.lineSpacing = label.leading;
        style.lineHeightMultiple = label.lineHeightMultiple;
        style.firstLineHeadIndent = label.firstLineIndent;
        style.paragraphSpacingBefore = label.textInsets.top;
        style.paragraphSpacing = label.textInsets.bottom;
        style.headIndent = label.textInsets.left;
        style.tailIndent = label.textInsets.right;
        if (label.numberOfLines == 1) {
            style.lineBreakMode = label.lineBreakMode;
        } else {
            style.lineBreakMode = NSLineBreakByWordWrapping;
        }
        [attrs setObject:style forKey:(NSString *)kCTParagraphStyleAttributeName];
    }
    return attrs;
}

@end