#import "MenuCell.h"


@implementation MenuCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
		self.selectionStyle = UITableViewCellSelectionStyleGray;
		self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
		self.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:0.111 green:0.165 blue:0.250 alpha:1.000]; //[UIColor colorWithRed:0.178 green:0.262 blue:0.397 alpha:1.000];
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
