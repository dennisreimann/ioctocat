#import "IOCMilestoneSelectionController.h"
#import "IOCMilestoneCell.h"
#import "GHRepository.h"
#import "GHMilestones.h"
#import "GHMilestone.h"
#import "GHIssue.h"
#import "SVProgressHUD.h"


@interface IOCMilestoneSelectionController ()
@property(nonatomic,weak)GHIssue *issue;
@property(nonatomic,strong)NSIndexPath *selectedIndexPath;
@end


@implementation IOCMilestoneSelectionController

- (id)initWithIssue:(GHIssue *)issue {
	self = [super initWithCollection:issue.repository.milestones];
    if (self) {
        _issue = issue;
    }
    return self;
}

- (NSString *)collectionName {
    return NSLocalizedString(@"Milestones", nil);
}

- (NSString *)collectionCellIdentifier {
    return @"MilestoneCell";
}

- (BOOL)canReload {
    return NO;
}

- (void)viewDidLoad {
	[super viewDidLoad];
    //self.tableView.rowHeight = 70;
	if (self.issue.milestone) {
        [self.collection whenLoaded:^(GHResource *instance, id data) {
            NSInteger row = [self.collection indexOfObject:self.issue.milestone];
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
    GHMilestone *oldMilestone = self.issue.milestone;
    GHMilestone *newMilestone = self.selectedIndexPath ? self.collection[self.selectedIndexPath.row] : nil;
    if (newMilestone != oldMilestone) {
        NSDictionary *params = @{@"milestone": newMilestone ? [NSString stringWithFormat:@"%d", newMilestone.number] : @""};
        [self.issue saveWithParams:params start:^(GHResource *instance) {
            [SVProgressHUD showWithStatus:@"Saving milestone" maskType:SVProgressHUDMaskTypeGradient];
        } success:^(GHResource *instance, id data) {
            [SVProgressHUD showSuccessWithStatus:@"Saved milestone"];
            self.issue.milestone = newMilestone;
            [self.issue markAsChanged];
            [self.delegate performSelector:@selector(savedResource:) withObject:self.issue];
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(GHResource *instance, NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Saving milestone failed"];
        }];
    }
}

#pragma mark TableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.collection.isEmpty) return [super tableView:tableView cellForRowAtIndexPath:indexPath];
	IOCMilestoneCell *cell = [tableView dequeueReusableCellWithIdentifier:self.collectionCellIdentifier];
	if (!cell) cell = [IOCMilestoneCell cellWithReuseIdentifier:self.collectionCellIdentifier];
	cell.milestone = self.collection[indexPath.row];
	cell.accessoryType = self.selectedIndexPath && self.selectedIndexPath.row == indexPath.row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.collection.isEmpty) return 44.0f;
    IOCMilestoneCell *cell = (IOCMilestoneCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    CGFloat height = [cell heightForTableView:tableView];
    return height;
}

@end