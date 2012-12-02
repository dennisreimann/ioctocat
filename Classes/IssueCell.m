#import "IssueCell.h"
#import "GHIssue.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "NSDate+Nibware.h"


@implementation IssueCell

- (void)setIssue:(GHIssue *)anIssue {
	_issue = anIssue;
	self.titleLabel.text = self.issue.title;
	self.detailLabel.text = self.issue.body;
	self.repoLabel.text = self.issue.repository.repoId;
	self.issueNumber.text = [NSString stringWithFormat:@"#%d", self.issue.num];
	self.dateLabel.text = [self.issue.updated prettyDate];
	// Icon
	NSString *icon = [NSString stringWithFormat:@"issues_%@.png", self.issue.state];
	self.iconView.image = [UIImage imageNamed:icon];
}

- (void)hideRepo {
	self.repoLabel.text = @"";
}

@end