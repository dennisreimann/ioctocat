#import <UIKit/UIKit.h>


@interface TextCell : UITableViewCell {
  @private
	IBOutlet UILabel *contentTextLabel;
}

@property (nonatomic, readonly) BOOL hasContent;
@property (nonatomic, readonly) CGFloat height;

- (void)setContentText:(NSString *)text;

@end
