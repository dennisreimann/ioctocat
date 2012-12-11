@class GHIssue;

@interface IssueCell : UITableViewCell
@property(nonatomic,strong)GHIssue *issue;

- (void)hideRepo;
@end