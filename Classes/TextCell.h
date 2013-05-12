@protocol TextCellDelegate <NSObject>
@optional
- (void)openURL:(NSURL *)url;
@end


@interface TextCell : UITableViewCell
@property(nonatomic,weak)id<TextCellDelegate> delegate;
@property(nonatomic,assign)NSInteger truncationLength;
@property(nonatomic,assign)BOOL linksEnabled;
@property(nonatomic,assign)BOOL emojiEnabled;
@property(nonatomic,assign)BOOL markdownEnabled;
@property(nonatomic,readonly)BOOL hasContent;

- (CGFloat)heightForTableView:(UITableView *)tableView;
- (void)setContentText:(NSString *)text;
@end