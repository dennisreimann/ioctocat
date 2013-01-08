#import "MenuCell.h"


@implementation MenuCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
		self.selectionStyle = UITableViewCellSelectionStyleGray;
		self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.textLabel.font = [UIFont systemFontOfSize:15];
		self.textLabel.textColor = [UIColor whiteColor];
    }
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect textFrame = self.textLabel.frame;
	textFrame.origin.x = 50;
	self.textLabel.frame = textFrame;
	self.imageView.frame = CGRectMake(6, 6, 32, 32);
	self.imageView.layer.cornerRadius = 3;
	self.imageView.layer.masksToBounds = YES;
}

@end
