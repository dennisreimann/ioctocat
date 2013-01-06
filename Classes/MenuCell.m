#import "MenuCell.h"


@implementation MenuCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont systemFontOfSize:15];
		self.selectionStyle = UITableViewCellSelectionStyleBlue;
		self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect textFrame = self.textLabel.frame;
	textFrame.origin.x = 46;
	self.textLabel.frame = textFrame;
	self.imageView.frame = CGRectMake(4, 4, 32, 32);
	self.imageView.layer.cornerRadius = 3;
	self.imageView.layer.masksToBounds = YES;
}

@end
