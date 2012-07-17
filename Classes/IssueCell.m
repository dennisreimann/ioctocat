#import "IssueCell.h"
#import "GHIssue.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "NSDate+Nibware.h"


@implementation IssueCell

@synthesize issue;

- (void)dealloc {
	[issue release], issue = nil;
	[dateLabel release], dateLabel = nil;
	[titleLabel release], titleLabel = nil;
	[detailLabel release], detailLabel = nil;    
    [votesLabel release], votesLabel = nil;    
    [repoLabel release], repoLabel = nil;       
    [iconView release], iconView = nil;        
    [super dealloc];
}

- (void)setIssue:(GHIssue *)anIssue {
	[issue release];
	issue = [anIssue retain];
	titleLabel.text = issue.title;
    detailLabel.text = issue.body;
	repoLabel.text = issue.repository.repoId;
    issueNumber.text = [NSString stringWithFormat:@"#%d", issue.num];
	dateLabel.text = [issue.updated prettyDate];
	// Icon
	NSString *icon = [NSString stringWithFormat:@"issues_%@.png", issue.state];
	iconView.image = [UIImage imageNamed:icon];
}

- (void)hideRepo {
	repoLabel.text = @"";
}

@end
