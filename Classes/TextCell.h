#import "TTTAttributedLabel.h"

@protocol TextCellDelegate <NSObject>
@optional
- (void)openURL:(NSURL *)url;
@end


@interface TextCell : UITableViewCell <TTTAttributedLabelDelegate>
@property(nonatomic,weak)id<TextCellDelegate> delegate;
@property(nonatomic,assign)NSInteger truncationLength;
@property(nonatomic,assign)BOOL linksEnabled;
@property(nonatomic,assign)BOOL emojiEnabled;
@property(nonatomic,assign)BOOL markdownEnabled;
@property(nonatomic,assign)BOOL markdownLinksEnabled;
@property(nonatomic,readonly)BOOL hasContent;
@property(nonatomic,strong)NSString *contentText;

- (CGFloat)heightForTableView:(UITableView *)tableView;
@end