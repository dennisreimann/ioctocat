#import "GHTextField.h"
#import <QuartzCore/QuartzCore.h>


@implementation GHTextField

- (void)awakeFromNib {
	CGColorRef lightGray = [UIColor colorWithWhite:0.853 alpha:1.000].CGColor;
	self.layer.borderColor = lightGray;
	self.layer.borderWidth = 1;
	self.layer.cornerRadius = 5.0f;
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
					  bounds.size.width - self.paddingHorizontal * 2,
					  bounds.size.height - self.paddingVertical * 2);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
	return [self textRectForBounds:bounds];
}

@end