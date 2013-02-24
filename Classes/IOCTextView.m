#import "IOCTextView.h"


@implementation IOCTextView

- (void)awakeFromNib {
	self.layer.cornerRadius = 5;
	self.layer.borderWidth = 1;
	self.layer.borderColor = [UIColor colorWithWhite:0.853 alpha:1.000].CGColor;
}

@end