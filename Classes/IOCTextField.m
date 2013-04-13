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

- (CGRect)textRectForBounds:(CGRect)bounds {
	return CGRectMake(bounds.origin.x + self.paddingHorizontal,
					  bounds.origin.y + self.paddingVertical,
					  bounds.size.width - self.paddingHorizontal * 2 - self.textRectSubtractOnRight,
					  bounds.size.height - self.paddingVertical * 2);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    CGRect editRect = [self textRectForBounds:bounds];
    editRect.size.width -= 20;
    return editRect;
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds {
    CGRect editRect = [self editingRectForBounds:bounds];
    CGRect clearRect = [super clearButtonRectForBounds:bounds];
    clearRect.origin.x = editRect.origin.x + editRect.size.width;
    return clearRect;
}

@end