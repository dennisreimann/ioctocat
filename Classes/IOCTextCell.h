#import "TTTAttributedLabel.h"

@protocol IOCTextCellDelegate <NSObject>
@optional
- (void)openURL:(NSURL *)url;
@end

@interface IOCTextCell : UITableViewCell <TTTAttributedLabelDelegate>
@property(nonatomic,weak)id<IOCTextCellDelegate> delegate;
@property(nonatomic,weak)NSString *contextRepoId;
@property(nonatomic,assign)BOOL linksEnabled;
@property(nonatomic,assign)BOOL emojiEnabled;
@property(nonatomic,assign)BOOL markdownEnabled;
@property(nonatomic,readonly)BOOL hasContent;
@property(nonatomic,strong)NSString *contentText;
@property(nonatomic,readonly)NSMutableDictionary *defaultAttributes;

- (CGFloat)heightForTableView:(UITableView *)tableView;
- (void)adjustContentTextHeight;
@end