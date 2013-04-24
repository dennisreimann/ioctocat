#import "IOCTextField.h"


@implementation IOCTextField

- (void)awakeFromNib {
	self.layer.cornerRadius = 5;
	self.layer.borderWidth = 1;
	self.layer.borderColor = [UIColor colorWithWhite:0.853 alpha:1.000].CGColor;
}

- (CGFloat)paddingHorizontal {
	return 8.0f;
}

- (CGFloat)paddingVertical {
	return 6.0f;
}

- (CGFloat)textRectSubtractOnRight {
    return self.clearWidth + _textRectSubtractOnRight;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
	return CGRectMake(bounds.origin.x + self.paddingHorizontal,
					  bounds.origin.y + self.paddingVertical,
					  bounds.size.width - self.paddingHorizontal * 2 - self.textRectSubtractOnRight,
					  bounds.size.height - self.paddingVertical * 2);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds {
    CGRect editRect = [self editingRectForBounds:bounds];
    CGRect clearRect = [super clearButtonRectForBounds:bounds];
    clearRect.origin.x = editRect.origin.x + editRect.size.width;
    return clearRect;
}

- (CGFloat)clearWidth {
    if ((self.clearButtonMode == UITextFieldViewModeAlways) ||
        (self.clearButtonMode == UITextFieldViewModeWhileEditing && self.isEditing) ||
        (self.clearButtonMode == UITextFieldViewModeUnlessEditing && !self.isEditing)) {
        return 20.0f;
    } else {
        return 0.0f;
    }
}

@end