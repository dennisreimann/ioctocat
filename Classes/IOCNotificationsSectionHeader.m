#import "IOCNotificationsSectionHeader.h"
#import "GradientButton.h"


@interface IOCNotificationsSectionHeader ()
@property(nonatomic,strong)GradientButton *titleButton;
@property(nonatomic,strong)GradientButton *markReadButton;
@end

@implementation IOCNotificationsSectionHeader

+ (instancetype)headerForTableView:(UITableView *)tableView title:(NSString *)title {
	IOCNotificationsSectionHeader *header = [super headerForTableView:tableView title:title];
    [header.titleLabel removeFromSuperview];
    
    // title button
    GradientButton *titleButton = [[GradientButton alloc] initWithFrame:header.titleLabel.frame];
    titleButton.autoresizingMask = header.titleLabel.autoresizingMask;
    titleButton.titleLabel.font = header.titleLabel.font;
    titleButton.frame = header.titleLabel.frame;
    titleButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    titleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [titleButton setTitle:title forState:UIControlStateNormal];
    [titleButton setTitleColor:header.titleLabel.textColor forState: UIControlStateNormal];
    [header addSubview:titleButton];
    header.titleButton = titleButton;
    
    // mark read button
    NSString *repo = [title lastPathComponent];
    UIFont *btnFont = [UIFont systemFontOfSize:13];
    NSString *btnTitle = [NSString stringWithFormat:@"Mark %@ as read", repo];
    CGSize btnSize = [btnTitle sizeWithFont:btnFont];
    CGFloat btnWidth = btnSize.width + 16;
    CGFloat btnHeight = btnSize.height + 8;
    CGFloat btnMargin = 5;
    CGFloat maxWidth = tableView.frame.size.width - header.titleLabel.frame.size.width - 25;
    if (btnWidth > maxWidth) btnWidth = maxWidth;
    GradientButton *button = [[GradientButton alloc] initWithFrame:CGRectMake(header.frame.size.width - btnWidth - btnMargin, btnMargin, btnWidth, btnHeight)];
    button.contentEdgeInsets = UIEdgeInsetsMake(2, 4, 2, 4);
    button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    button.titleLabel.font = btnFont;
    [button useDarkGithubStyle];
    button.cornerRadius = 3.f;
    [button setTitle:btnTitle forState:UIControlStateNormal];
    [header addSubview:button];
    header.markReadButton = button;
    
    return header;
}

@end