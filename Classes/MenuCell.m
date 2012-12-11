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
    self.imageView.frame = CGRectMake(4, 4, 32, 32);
}

@end
