#import "IOCMenuCell.h"


@implementation IOCMenuCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
		self.selectionStyle = UITableViewCellSelectionStyleGray;
		self.imageView.contentMode = UIViewContentModeScaleAspectFit;
		self.imageView.layer.cornerRadius = 3;
		self.imageView.layer.masksToBounds = YES;
        self.textLabel.font = [UIFont systemFontOfSize:15];
		self.textLabel.textColor = [UIColor whiteColor];
		self.badgeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		self.badgeLabel.textAlignment = NSTextAlignmentCenter;
		self.badgeLabel.textColor = [UIColor whiteColor];
		self.badgeLabel.font = [UIFont systemFontOfSize:15];
		self.badgeLabel.layer.cornerRadius = 15;
		self.badgeLabel.text = nil;
		[self addSubview:self.badgeLabel];
    }
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect textFrame = self.textLabel.frame;
	textFrame.origin.x = 50;
	self.textLabel.frame = textFrame;
	if (self.badgeLabel.text) {
		[self.imageView setHidden:YES];
		self.badgeLabel.frame = CGRectMake(7, 6, 30, 30);
		self.badgeLabel.backgroundColor = [self.badgeLabel.text intValue] == 0 ?
			self.badgeEmptyBackgroundColor :
			self.badgeHighlightBackgroundColor;
		[self.badgeLabel setHidden:NO];
	} else {
		[self.badgeLabel setHidden:YES];
		self.imageView.frame = CGRectMake(6, 6, 32, 32);
		[self.imageView setHidden:NO];
	}
}

- (UIColor *)badgeEmptyBackgroundColor {
	return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone ?
		[UIColor colorWithRed:0.176 green:0.261 blue:0.401 alpha:1.000] :
		[UIColor colorWithRed:0.240 green:0.268 blue:0.297 alpha:1.000];
}

- (UIColor *)badgeHighlightBackgroundColor {
	return [UIColor colorWithRed:0.000 green:0.509 blue:0.747 alpha:1.000];
}


@end
