#import "MenuTableView.h"

@implementation MenuTableView

- (void)setContentSize:(CGSize)contentSize {
    contentSize.height -= self.tableFooterView.frame.size.height;
    [super setContentSize:contentSize];
}

@end