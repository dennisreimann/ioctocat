#import "IOCLabeledCell.h"
#import "NSString_IOCExtensions.h"


@interface IOCLabeledCell ()
@property(nonatomic,assign)BOOL hasContent;
@property(nonatomic,weak)IBOutlet UILabel *label;
@property(nonatomic,weak)IBOutlet UILabel *content;
@end


@implementation IOCLabeledCell

- (void)setLabelText:(NSString *)text {
	self.label.text = text;
}

- (NSString *)emptyText {
    if (!_emptyText) {
        _emptyText = NSLocalizedString(@"n/a", @"Labeled Cell: not available (indicates no content)");
    }
    return _emptyText;
}

- (void)setContentText:(NSString *)text {
	self.hasContent = (![text isKindOfClass:NSNull.class] && text != nil && ![text ioc_isEmpty]);
	self.content.text = self.hasContent ? text : self.emptyText;
	self.content.textColor = self.hasContent ? [UIColor blackColor] : [UIColor grayColor];
	self.content.highlightedTextColor = [UIColor whiteColor];
}

@end