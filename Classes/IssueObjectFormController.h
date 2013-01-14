@protocol IssueObjectFormControllerDelegate <NSObject>
- (void)savedIssueObject:(id)object;
@end

@interface IssueObjectFormController : UITableViewController
@property(nonatomic,weak)id<IssueObjectFormControllerDelegate> delegate;

- (id)initWithIssueObject:(id)object;
@end