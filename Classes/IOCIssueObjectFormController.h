@protocol IOCIssueObjectFormControllerDelegate <NSObject>
- (void)savedIssueObject:(id)object;
@end

@interface IOCIssueObjectFormController : UIViewController
@property(nonatomic,weak)id<IOCIssueObjectFormControllerDelegate> delegate;

- (id)initWithIssueObject:(id)object;
@end