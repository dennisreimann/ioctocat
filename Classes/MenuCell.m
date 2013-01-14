#import "MenuCell.h"


@interface MenuCell ()
@property(nonatomic,strong)UILabel *badgeLabel;
@end


@implementation MenuCell

- (void)awakeFromNib {
	self.badgeLabel.layer.masksToBounds = YES;
	self.badgeLabel.layer.cornerRadius = 9.0;
}

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
		self.badgeLabel.textAlignment = UITextAlignmentCenter;
		self.badgeLabel.textColor = [UIColor whiteColor];
		self.badgeLabel.font = [UIFont systemFontOfSize:15];
		self.badgeLabel.layer.cornerRadius = 13;
		self.badgeCount = (int)nil;
		[self addSubview:self.badgeLabel];
    }
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGRect textFrame = self.textLabel.frame;
	textFrame.origin.x = 50;
	self.textLabel.frame = textFrame;
	// Badge
	if (self.badgeCount) {
		[self.imageView setHidden:YES];
		self.badgeLabel.text = [NSString stringWithFormat:@"%d", self.badgeCount];
		self.badgeLabel.frame = CGRectMake(10, 8, 26, 26);
		self.badgeLabel.backgroundColor = self.badgeCount == 0 ?
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
	return [UIColor colorWithRed:0.818 green:0.120 blue:0.118 alpha:1.000];
}


@end
