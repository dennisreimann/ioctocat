#import "IssueCommentController.h"
#import "NSString+Extensions.h"
#import "GHIssueComments.h"
#import "GHIssueComment.h"


@implementation IssueCommentController

- (id)initWithIssue:(GHIssue *)theIssue {    
    [super initWithNibName:@"IssueComment" bundle:nil];
	
	issue = [theIssue retain];
	comment = [[GHIssueComment alloc] initWithIssue:issue];
    [comment addObserver:self forKeyPath:kResourceSavingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Post comment";
	self.navigationItem.rightBarButtonItem = postButton;
	
	[bodyView becomeFirstResponder];
}

- (void)dealloc {
	[comment removeObserver:self forKeyPath:kResourceSavingStatusKeyPath];
	[comment release];
	[issue release];
	[bodyView release];
	[postButton release];
	[activityView release];
	
    [super dealloc];
}

- (IBAction)postComment:(id)sender {
	comment.body = bodyView.text;
	
	// Validate
	if ([comment.body isEmpty]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Validation failed" message:@"Please enter a text" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	} else {
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:activityView] autorelease];
		[comment saveData];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:kResourceSavingStatusKeyPath]) {
		if (comment.isSaving) return;
		if (comment.isSaved) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Comment saved" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
			[issue.comments loadData];
			[self.navigationController popViewControllerAnimated:YES];
		} else if (comment.error) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Request error" message:@"Could not proceed the request" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
		self.navigationItem.rightBarButtonItem = postButton;
	}
}

#pragma mark Autorotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}

@end
