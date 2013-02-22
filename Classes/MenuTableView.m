#import "MenuTableView.h"

@implementation MenuTableView

- (void)setContentSize:(CGSize)contentSize {
    if (self.tableFooterView) {
        contentSize.height -= self.tableFooterView.frame.size.height;
    }
    [super setContentSize:contentSize];
}

@end