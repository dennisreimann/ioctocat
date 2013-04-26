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
#import "IOCTreeController.h"
#import "IOCBlobsController.h"
#import "GHUser.h"
#import "GHGist.h"
#import "GHBlob.h"
#import "GHTree.h"
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
#import "NSDictionary+Extensions.h"


@implementation IOCViewControllerFactory

+ (UIViewController *)viewControllerForGitHubURL:(NSURL *)url {
    NSArray *staticPages = @[@"about", @"blog", @"contact", @"edu", @"plans"];
    NSArray *comps = url.pathComponents;
	UIViewController *viewController = nil;
	DJLog(@"%@", comps);
	// the first pathComponent is always "/"
	if ([url.host isEqualToString:@"gist.github.com"]) {
        if (comps.count == 2) {
			// Gists
            NSString *login = comps[1];
            GHUser *user = [iOctocat.sharedInstance userWithLogin:login];
            viewController = [[IOCGistsController alloc] initWithGists:user.gists];
        } else if (comps.count == 3) {
			// Gist
            NSString *gistId = comps[2];
			GHGist *gist = [[GHGist alloc] initWithId:gistId];
            gist.htmlURL = url;
			viewController = [[IOCGistController alloc] initWithGist:gist];
		}
	} else {
        BOOL isStatic = comps.count == 1 || (comps.count >= 2 && [staticPages containsObject:comps[1]]);
        if (isStatic) {
            NSURL *pageURL = [NSURL URLWithFormat:@"%@%@", kGitHubComURL, url.path];
            viewController = [[WebController alloc] initWithURL:pageURL];
        } else if (comps.count == 2) {
            NSString *component = comps[1];
            if ([component isEqualToString:@"search"]) {
                viewController = [[IOCSearchController alloc] init];
            } else{
                // User (or Organization)
                GHUser *user = [iOctocat.sharedInstance userWithLogin:component];
                user.htmlURL = url;
                viewController = [[IOCUserController alloc] initWithUser:user];
            }
        } else if (comps.count >= 3) {
            // Repository
            NSString *owner = comps[1];
            NSString *name = comps[2];
            GHRepository *repo = [[GHRepository alloc] initWithOwner:owner andName:name];
            if (comps.count == 3) {
                repo.htmlURL = url;
                viewController = [[IOCRepositoryController alloc] initWithRepository:repo];
            } else if (comps.count == 4 && [comps[3] isEqualToString:@"issues"]) {
                // Issues
                viewController = [[IOCIssuesController alloc] initWithRepository:repo];
            } else if (comps.count == 4 && [comps[3] isEqualToString:@"pull"]) {
                // Pull Requests
                viewController = [[IOCPullRequestsController alloc] initWithRepository:repo];
            } else if (comps.count == 5 && [comps[3] isEqualToString:@"issues"]) {
                // Issue
                GHIssue *issue = [[GHIssue alloc] initWithRepository:repo];
                issue.number = [comps[4] intValue];
                viewController = [[IOCIssueController alloc] initWithIssue:issue];
            } else if (comps.count == 5 && [comps[3] isEqualToString:@"pull"]) {
                // Pull Request
                GHPullRequest *pullRequest = [[GHPullRequest alloc] initWithRepository:repo];
                pullRequest.number = [comps[4] intValue];
                viewController = [[IOCPullRequestController alloc] initWithPullRequest:pullRequest];
            } else if (comps.count == 5 && [comps[3] isEqualToString:@"commit"]) {
                // Commit
                NSString *sha = comps[4];
                GHCommit *commit = [[GHCommit alloc] initWithRepository:repo andCommitID:sha];
                viewController = [[IOCCommitController alloc] initWithCommit:commit];
            } else if (comps.count >= 4) {
                NSString *type = comps[3];
                NSString *ref = comps[4];
                NSString *path = [[comps subarrayWithRange:NSMakeRange(5, comps.count - 5)] componentsJoinedByString:@"/"];
                if ([type isEqualToString:@"tree"]) {
                    // Tree
                    GHTree *tree = [[GHTree alloc] initWithRepo:repo path:path ref:ref];
                    viewController = [[IOCTreeController alloc] initWithTree:tree];
                } else if ([type isEqualToString:@"blob"]) {
                    // Blob
                    GHBlob *blob = [[GHBlob alloc] initWithRepo:repo path:path ref:ref];
                    viewController = [[IOCBlobsController alloc] initWithBlob:blob];
                }
            }
        }
	}
	return viewController;
}

@end