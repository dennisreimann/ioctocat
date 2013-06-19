#import "IOCAssigneeSelectionController.h"
#import "IOCUserObjectCell.h"
#import "GHRepository.h"
#import "GHIssue.h"
#import "GHUsers.h"
#import "GHUser.h"
#import "SVProgressHUD.h"


@interface IOCAssigneeSelectionController ()
@property(nonatomic,weak)GHIssue *issue;
@property(nonatomic,strong)NSIndexPath *selectedIndexPath;
@end


@implementation IOCAssigneeSelectionController

- (id)initWithIssue:(GHIssue *)issue {
	self = [super initWithCollection:issue.repository.assignees];
    if (self) {
        _issue = issue;
    }
    return self;
}

- (NSString *)collectionName {
    return NSLocalizedString(@"Assignees", nil);
}

- (NSString *)collectionCellIdentifier {
    return kUserObjectCellIdentifier;
}

- (BOOL)canReload {
    return NO;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	if (self.issue.assignee) {
        [self.collection whenLoaded:^(GHResource *instance, id data) {
            NSInteger row = [self.collection indexOfObject:self.issue.assignee];
            self.selectedIndexPath = [NSIndexPath indexPathForRow:row inSection:0];
            [self.tableView reloadData];
        }];
    } else {
        self.selectedIndexPath = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
    if (!self.collection.isLoaded) return;
    GHUser *oldAssignee = self.issue.assignee;
    GHUser *newAssignee = self.selectedIndexPath ? self.collection[self.selectedIndexPath.row] : nil;
    if (newAssignee != oldAssignee) {
        NSDictionary *params = @{@"assignee": newAssignee ? newAssignee.login : @""};
        [self.issue saveWithParams:params start:^(GHResource *instance) {
            [SVProgressHUD showWithStatus:@"Saving assignee" maskType:SVProgressHUDMaskTypeGradient];
        } success:^(GHResource *instance, id data) {
            [SVProgressHUD showSuccessWithStatus:@"Saved assignee"];
            self.issue.assignee = newAssignee;
            [self.issue markAsChanged];
            [self.delegate performSelector:@selector(savedResource:) withObject:self.issue];
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(GHResource *instance, NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Saving assignee failed"];
        }];
    }
}

#pragma mark TableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.collection.isEmpty) return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    NSInteger row = indexPath.row;
	IOCUserObjectCell *cell = (IOCUserObjectCell *)[tableView dequeueReusableCellWithIdentifier:self.collectionCellIdentifier];
	if (!cell) {
        cell = [IOCUserObjectCell cellWithReuseIdentifier:self.collectionCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    GHUser *user = self.collection[row];
    cell.userObject = user;
    cell.accessoryType = self.selectedIndexPath && self.selectedIndexPath.row == row? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.collection.isEmpty) return;
    UITableViewCell *cell = nil;
    if (self.selectedIndexPath) {
        cell = [tableView cellForRowAtIndexPath:self.selectedIndexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    if ([self.selectedIndexPath isEqual:indexPath]) {
        self.selectedIndexPath = nil;
    } else {
        cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.selectedIndexPath = indexPath;
    }
}

@end