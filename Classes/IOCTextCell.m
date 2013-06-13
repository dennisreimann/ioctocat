#import "IOCTextCell.h"
#import "NSString+Emojize.h"
#import "NSString+Extensions.h"
#import "GHFMarkdown.h"
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
    // parse and modify label text
    if (self.emojiEnabled) text = [text emojizedString];
    if (self.markdownEnabled) {
        NSMutableAttributedString *attributedText = [text mutableAttributedStringFromGHFMarkdownWithContextRepoId:self.contextRepoId attributes:self.defaultAttributes];
        // set up attributes
        UIFont *font = self.contentLabel.font;
        CGFloat fontSize = font.pointSize;
        CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName, fontSize, NULL);
        CTFontRef boldFontRef = CTFontCreateCopyWithSymbolicTraits(fontRef, fontSize, NULL, kCTFontBoldTrait, (kCTFontBoldTrait | kCTFontItalicTrait));
        CTFontRef italicFontRef = CTFontCreateCopyWithSymbolicTraits(fontRef, fontSize, NULL, kCTFontItalicTrait, (kCTFontBoldTrait | kCTFontItalicTrait));
        CTFontRef boldItalicFontRef = CTFontCreateCopyWithSymbolicTraits(fontRef, fontSize, NULL, (kCTFontBoldTrait | kCTFontItalicTrait), (kCTFontBoldTrait | kCTFontItalicTrait));
        // fix for cases in that font ref variants cannot be resolved - looking at you, HelveticaNeue!
        if (!boldItalicFontRef || !italicFontRef) {
            UIFont *boldFont = [UIFont boldSystemFontOfSize:fontSize];
            UIFont *italicFont = [UIFont italicSystemFontOfSize:fontSize];
            if (!boldFontRef) boldFontRef = CTFontCreateWithName((__bridge CFStringRef)boldFont.fontName, fontSize, NULL);
            if (!italicFontRef) italicFontRef = CTFontCreateWithName((__bridge CFStringRef)italicFont.fontName, fontSize, NULL);
            if (!boldItalicFontRef) boldItalicFontRef = CTFontCreateCopyWithSymbolicTraits(italicFontRef, fontSize, NULL, kCTFontBoldTrait, kCTFontBoldTrait);
        }
        CTFontRef h1FontRef = CTFontCreateCopyWithAttributes(boldFontRef, fontSize + 6, NULL, NULL);
        CTFontRef h2FontRef = CTFontCreateCopyWithAttributes(boldFontRef, fontSize + 4, NULL, NULL);
        CTFontRef h3FontRef = CTFontCreateCopyWithAttributes(boldFontRef, fontSize + 2, NULL, NULL);
        NSDictionary *h1Attributes = [NSDictionary dictionaryWithObject:(__bridge id)h1FontRef forKey:(NSString *)kCTFontAttributeName];
        NSDictionary *h2Attributes = [NSDictionary dictionaryWithObject:(__bridge id)h2FontRef forKey:(NSString *)kCTFontAttributeName];
        NSDictionary *h3Attributes = [NSDictionary dictionaryWithObject:(__bridge id)h3FontRef forKey:(NSString *)kCTFontAttributeName];
        NSDictionary *boldAttributes = [NSDictionary dictionaryWithObject:(__bridge id)boldFontRef forKey:(NSString *)kCTFontAttributeName];
        NSDictionary *italicAttributes = [NSDictionary dictionaryWithObject:(__bridge id)italicFontRef forKey:(NSString *)kCTFontAttributeName];
        NSDictionary *boldItalicAttributes = [NSDictionary dictionaryWithObject:(__bridge id)boldItalicFontRef forKey:(NSString *)kCTFontAttributeName];
        NSDictionary *codeAttributes = [NSDictionary dictionaryWithObjects:@[[UIFont fontWithName:@"Courier" size:fontSize], (id)[[UIColor darkGrayColor] CGColor]] forKeys:@[(NSString *)kCTFontAttributeName, (NSString *)kCTForegroundColorAttributeName]];
        NSDictionary *quoteAttributes = [NSDictionary dictionaryWithObjects:@[(id)[[UIColor grayColor] CGColor]] forKeys:@[(NSString *)kCTForegroundColorAttributeName]];
        // apply attributes
        [attributedText applyAttributes:@{
         @"GHFMarkdown_Headline1": h1Attributes,
         @"GHFMarkdown_Headline2": h2Attributes,
         @"GHFMarkdown_Headline3": h3Attributes,
         @"GHFMarkdown_Headline4": boldAttributes,
         @"GHFMarkdown_Headline5": boldAttributes,
         @"GHFMarkdown_Headline6": boldAttributes,
         @"GHFMarkdown_Bold": boldAttributes,
         @"GHFMarkdown_Italic": italicAttributes,
         @"GHFMarkdown_BoldItalic": boldItalicAttributes,
         @"GHFMarkdown_CodeBlock": codeAttributes,
         @"GHFMarkdown_CodeInline": codeAttributes,
         @"GHFMarkdown_Quote": quoteAttributes}];
        // set text
        self.contentLabel.text = attributedText;
        // add links
        NSRange range = NSMakeRange(0, attributedText.length);
        [attributedText enumerateAttribute:@"GHFMarkdown_Link" inRange:range options:NULL usingBlock:^(id url, NSRange range, BOOL *stop) {
            if (url) [self.contentLabel addLinkToURL:url withRange:range];
        }];
        // release font refs
        CFRelease(fontRef);
        CFRelease(h1FontRef);
        CFRelease(h2FontRef);
        CFRelease(h3FontRef);
        CFRelease(boldFontRef);
        CFRelease(italicFontRef);
        CFRelease(boldItalicFontRef);
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

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return action == @selector(copy:);
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
        style.lineBreakMode = (label.numberOfLines == 1) ? label.lineBreakMode : NSLineBreakByWordWrapping;
        [attrs setObject:style forKey:(NSString *)kCTParagraphStyleAttributeName];
    }
    return attrs;
}

@end