#import "IOCNotificationsSectionHeader.h"
#import "GradientButton.h"


@interface IOCNotificationsSectionHeader ()
@property(nonatomic,strong)UIButton *titleButton;
@property(nonatomic,strong)GradientButton *markReadButton;
@end

@implementation IOCNotificationsSectionHeader

+ (instancetype)headerForTableView:(UITableView *)tableView title:(NSString *)title {
	IOCNotificationsSectionHeader *header = [super headerForTableView:tableView title:title];
	
    UIFont *btnFont = [UIFont systemFontOfSize:13];
    NSString *repo = [title lastPathComponent];
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
    [button addTarget:self action:@selector(markAllAsReadInSection:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:btnTitle forState:UIControlStateNormal];
    [header addSubview:button];
    header.markReadButton = button;
    
    return header;
}

@end