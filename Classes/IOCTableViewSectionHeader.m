#import "IOCTableViewSectionHeader.h"


@interface IOCTableViewSectionHeader ()
@property(nonatomic,strong)UILabel *titleLabel;
@end

@implementation IOCTableViewSectionHeader

+ (instancetype)headerForTableView:(UITableView *)tableView title:(NSString *)title {
	CGFloat width = tableView.frame.size.width;
	CGFloat height = 24;
	IOCTableViewSectionHeader *view = [[super alloc] initWithFrame:CGRectMake(0, 0, width, height)];
	view.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    view.titleLabel = [[UILabel alloc] init];
    view.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	view.titleLabel.backgroundColor = [UIColor clearColor];
    view.titleLabel.textColor = [UIColor colorWithWhite:0.391 alpha:1.000];
    view.titleLabel.font = [UIFont boldSystemFontOfSize:13];
	view.titleLabel.text = title;
	CGSize titleSize = [view.titleLabel.text sizeWithFont:view.titleLabel.font];
	view.titleLabel.frame = CGRectMake(10, 0, titleSize.width, view.frame.size.height);

    CAGradientLayer *gradient = [CAGradientLayer layer];
	gradient.frame = view.frame;
	gradient.colors = @[
		(id)[UIColor colorWithWhite:0.980 alpha:1.000].CGColor,
		(id)[UIColor colorWithWhite:0.902 alpha:1.000].CGColor];
	[view.layer insertSublayer:gradient atIndex:0];
	[view addSubview:view.titleLabel];

    return view;
}

-(void)layoutSubviews {
	CAGradientLayer *gradient = [self.layer.sublayers objectAtIndex:0];
    gradient.frame = self.bounds;
}

@end