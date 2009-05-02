#import "IssueCell.h"
#import "GHIssue.h"
#import "GHUser.h"


@implementation IssueCell

@synthesize issue;

- (void)setIssue:(GHIssue *)anIssue {
	[issue release];
	issue = [anIssue retain];
	titleLabel.text = issue.title;
    detailLabel.text = issue.body;
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	dateLabel.text = [dateFormatter stringFromDate:issue.created];
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
