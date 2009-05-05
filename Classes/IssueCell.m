#import "IssueCell.h"
#import "GHIssue.h"
#import "GHUser.h"
#import "NSDate+Nibware.h"

@implementation IssueCell

@synthesize issue;

- (void)setIssue:(GHIssue *)anIssue {
	[issue release];
	issue = [anIssue retain];
	titleLabel.text = issue.title;
    detailLabel.text = issue.body;
    issueNumber.text = [NSString stringWithFormat:@"#%d", issue.num];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	dateLabel.text = [issue.created prettyDate];//   [dateFormatter stringFromDate:issue.created];
	[dateFormatter release];
	// Icon
	NSString *icon = [NSString stringWithFormat:@"issues_%@.png", issue.state];
	iconView.image = [UIImage imageNamed:icon];
}

- (void)dealloc {
	[issue release];
	[dateLabel release];
	[titleLabel release];
	[detailLabel release];    
    [votesLabel release];        
    [iconView release];        
    [super dealloc];
}

@end
