#import "IOCTableViewSectionHeader.h"


@implementation IOCTableViewSectionHeader

+ (IOCTableViewSectionHeader *)headerForTableView:(UITableView *)tableView title:(NSString *)title {
	CGFloat width = tableView.frame.size.width;
	CGFloat height = 24;
	IOCTableViewSectionHeader *view = [[super alloc] initWithFrame:CGRectMake(0, 0, width, height)];
	view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(10, 0, view.frame.size.width - 20, view.frame.size.height);
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithWhite:0.391 alpha:1.000];
    label.font = [UIFont boldSystemFontOfSize:13];
	label.text = title;

    CAGradientLayer *gradient = [CAGradientLayer layer];
	gradient.frame = view.frame;
	gradient.colors = @[
		(id)[UIColor colorWithWhite:0.980 alpha:1.000].CGColor,
		(id)[UIColor colorWithWhite:0.902 alpha:1.000].CGColor];
	[view.layer insertSublayer:gradient atIndex:0];
	[view addSubview:label];

    return view;
}

-(void)layoutSubviews {
	CAGradientLayer *gradient = [self.layer.sublayers objectAtIndex:0];
    gradient.frame = self.bounds;
}

@end