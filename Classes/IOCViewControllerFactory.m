#import "IOCViewControllerFactory.h"
#import "WebController.h"
#import "IOCUserController.h"
#import "IOCRepositoryController.h"
#import "IOCIssueController.h"
#import "IOCIssuesController.h"
#import "IOCPullRequestController.h"
#import "IOCPullRequestsController.h"
#import "IOCGistController.h"
#import "IOCGistsController.h"
#import "IOCCommitController.h"
#import "IOCSearchController.h"
#import "GHUser.h"
#import "GHGist.h"
#import "GHCommit.h"
#import "GHIssue.h"
#import "GHIssues.h"
#import "GHPullRequest.h"
#import "GHOrganization.h"
#import "GHOrganizations.h"
#import "GHNotifications.h"
#import "GHNotification.h"
#import "GHRepository.h"
#import "iOctocat.h"
#import "NSURL+Extensions.h"


@implementation IOCViewControllerFactory

+ (UIViewController *)viewControllerForGitHubURL:(NSURL *)url {
	UIViewController *viewController = nil;
	DJLog(@"%@", url.pathComponents);
	// the first pathComponent is always "/"
	if ([url.host isEqualToString:@"gist.github.com"]) {
        if (url.pathComponents.count == 2) {
			// Gists
            NSString *login = [url.pathComponents objectAtIndex:1];
            GHUser *user = [iOctocat.sharedInstance userWithLogin:login];
            viewController = [[IOCGistsController alloc] initWithGists:user.gists];
        } else if (url.pathComponents.count == 3) {
			// Gist
            NSString *gistId = [url.pathComponents objectAtIndex:2];
			GHGist *gist = [[GHGist alloc] initWithId:gistId];
            gist.htmlURL = url;
			viewController = [[IOCGistController alloc] initWithGist:gist];
		}
	} else if (url.pathComponents.count == 2) {
        NSArray *staticPages = @[@"about", @"blog", @"contact", @"edu", @"plans"];
		NSString *component = [url.pathComponents objectAtIndex:1];
        if ([staticPages containsObject:component]) {
            NSURL *pageURL = [NSURL URLWithFormat:@"%@%@", kGitHubComURL, component];
            viewController = [[WebController alloc] initWithURL:pageURL];
        } else if ([component isEqualToString:@"search"]) {
            viewController = [[IOCSearchController alloc] init];
        } else{
            // User (or Organization)
            GHUser *user = [[iOctocat sharedInstance] userWithLogin:component];
            user.htmlURL = url;
            viewController = [[IOCUserController alloc] initWithUser:user];
        }
	} else if (url.pathComponents.count >= 3) {
		// Repository
		NSString *owner = [url.pathComponents objectAtIndex:1];
		NSString *name = [url.pathComponents objectAtIndex:2];
		GHRepository *repo = [[GHRepository alloc] initWithOwner:owner andName:name];
		if (url.pathComponents.count == 3) {
            repo.htmlURL = url;
			viewController = [[IOCRepositoryController alloc] initWithRepository:repo];
		} else if (url.pathComponents.count == 4 && [[url.pathComponents objectAtIndex:3] isEqualToString:@"issues"]) {
			// Issues
			viewController = [[IOCIssuesController alloc] initWithRepository:repo];
		} else if (url.pathComponents.count == 4 && [[url.pathComponents objectAtIndex:3] isEqualToString:@"pull"]) {
			// Pull Requests
			viewController = [[IOCPullRequestsController alloc] initWithRepository:repo];
		} else if (url.pathComponents.count == 5 && [[url.pathComponents objectAtIndex:3] isEqualToString:@"issues"]) {
			// Issue
			GHIssue *issue = [[GHIssue alloc] initWithRepository:repo];
			issue.num = [[url.pathComponents objectAtIndex:4] intValue];
			viewController = [[IOCIssueController alloc] initWithIssue:issue];
		} else if (url.pathComponents.count == 5 && [[url.pathComponents objectAtIndex:3] isEqualToString:@"pull"]) {
			// Pull Request
			GHPullRequest *pullRequest = [[GHPullRequest alloc] initWithRepository:repo];
			pullRequest.num = [[url.pathComponents objectAtIndex:4] intValue];
			viewController = [[IOCPullRequestController alloc] initWithPullRequest:pullRequest];
		} else if (url.pathComponents.count == 5 && [[url.pathComponents objectAtIndex:3] isEqualToString:@"commit"]) {
			// Commit
			NSString *sha = [url.pathComponents objectAtIndex:4];
			GHCommit *commit = [[GHCommit alloc] initWithRepository:repo andCommitID:sha];
			viewController = [[IOCCommitController alloc] initWithCommit:commit];
		}
	}
	return viewController;
}

@end