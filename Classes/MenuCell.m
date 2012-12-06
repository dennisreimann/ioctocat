#import <QuartzCore/QuartzCore.h>
#import "MenuCell.h"


@implementation MenuCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont systemFontOfSize:15];
		self.selectionStyle = UITableViewCellSelectionStyleBlue;
		self.imageView.contentMode = UIViewContentModeScaleAspectFit;

//		CGRect frame = self.frame;
//		frame.size.height = 40;
//		self.selectedBackgroundView = [[UIView alloc] initWithFrame:frame];
//		CAGradientLayer *gradient = [CAGradientLayer layer];
//		gradient.frame = frame;
//		gradient.colors = [NSArray arrayWithObjects:
//						   (id)[UIColor colorWithRed:0.922 green:0.945 blue:0.967 alpha:1.000].CGColor,
//						   (id)[UIColor colorWithRed:0.771 green:0.829 blue:0.894 alpha:1.000].CGColor, nil];
//		[self.selectedBackgroundView.layer insertSublayer:gradient atIndex:0];
//		self.textLabel.highlightedTextColor = [UIColor colorWithRed:0.198 green:0.425 blue:0.743 alpha:1.000];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(4, 4, 32, 32);
}

@end
