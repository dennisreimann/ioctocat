#import <UIKit/UIKit.h>


@interface TextCell : UITableViewCell {
  @private
	IBOutlet UILabel *contentTextLabel;
	CGFloat maxWidth;
}

@property(nonatomic,readonly)BOOL hasContent;
@property(nonatomic,readonly)CGFloat height;

- (void)setContentText:(NSString *)text;

@end
