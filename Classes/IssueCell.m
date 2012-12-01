#import "IssueCell.h"
#import "GHIssue.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "NSDate+Nibware.h"


@implementation IssueCell

- (void)dealloc {
	[_issue release], _issue = nil;
	[_dateLabel release], _dateLabel = nil;
	[_titleLabel release], _titleLabel = nil;
	[_detailLabel release], _detailLabel = nil;
	[_votesLabel release], _votesLabel = nil;
	[_repoLabel release], _repoLabel = nil;
	[_iconView release], _iconView = nil;
	[super dealloc];
}

- (void)setIssue:(GHIssue *)anIssue {
	[anIssue retain];
	[_issue release];
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