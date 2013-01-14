@interface IssueObjectCell : UITableViewCell
@property(nonatomic,strong)id issueObject;

+ (id)cell;
+ (id)cellWithIdentifier:(NSString *)reuseIdentifier;
- (void)hideRepo;
@end