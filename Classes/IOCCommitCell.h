@class GHCommit;

@interface IOCCommitCell : UITableViewCell
@property(nonatomic,strong)GHCommit *commit;

+ (id)cellWithReuseIdentifier:(NSString *)reuseIdentifier;
@end
