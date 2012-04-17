// Settings
#define kClearAvatarCacheDefaultsKey @"clearAvatarCache"
#define kLastReadingDateURLDefaultsKeyPrefix @"lastReadingDate:"
#define kLoginDefaultsKey @"username"
#define kPasswordDefaultsKey @"password"

// API
#define kISO8601TimeFormat @"yyyy-MM-dd'T'HH:mm:ssz"

// Tables
#define kRepositoryCellIdentifier @"RepositoryCell"
#define kFeedEntryCellIdentifier @"FeedEntryCell"
#define kIssueCellIdentifier @"IssueCell"
#define kUserCellIdentifier @"UserCell"
#define kBranchCellIdentifier @"BranchCell"
#define kCommentCellIdentifier @"CommentCell"
#define kOrganizationCellIdentifier @"OrganizationCell"

// User
#define kUserGithubFormat @"https://github.com/%@"
#define kUserFeedFormat @"https://github.com/%@.atom"                                     // non-API atom
#define kUserNewsFeedFormat @"https://github.com/%@.private.atom"                         // non-API atom
#define kUserActivityFeedFormat @"https://github.com/%@.private.actor.atom"               // non-API atom
#define kUserAuthenticatedFormat @"https://api.github.com/user"                           // v3
#define kUserAuthenticatedOrgsFormat @"https://api.github.com/user/orgs"                  // v3 not announced
#define kUserOrganizationsFormat @"https://api.github.com/users/%@/orgs"                  // v3 not announced
#define kUserFormat @"https://api.github.com/users/%@"                                    // v3
#define kUserAuthenticatedReposFormat @"https://api.github.com/user/repos?per_page=100"   // v3
#define kUserReposFormat @"https://api.github.com/users/%@/repos?per_page=100"            // v3
#define kUserWatchedReposFormat @"https://api.github.com/users/%@/watched?per_page=100"   // v3
#define kUserFollowingFormat @"https://api.github.com/users/%@/following?per_page=100"    // v3
#define kUserFollowersFormat @"https://api.github.com/users/%@/followers?per_page=100"    // v3
#define kUserFollowFormat @"https://api.github.com/user/following/%@"                     // v3
#define kUserSearchFormat @"https://github.com/api/v2/json/user/search/%@"                // v3 not available

// Repos
#define kRepoGithubFormat @"https://github.com/%@/%@"
#define kRepoFeedFormat @"https://github.com/feeds/%@/commits/%@/%@"                      // non-API atom
#define kRepoPrivateFeedFormat @"https://github.com/feeds/%@/commits/%@/%@"               // non-API atom
#define kRepoFormat @"https://api.github.com/repos/%@/%@"                                 // v3
#define kRepoWatchFormat @"https://api.github.com/user/watched/%@/%@"                     // v3
#define kRepoBranchesFormat @"https://api.github.com/repos/%@/%@/branches"                // v3 not announced
#define kRepoForksFormat @"https://api.github.com/repos/%@/%@/forks"                      // v3
#define kRepoCommitsFormat @"https://api.github.com/repos/%@/%@/commits"                  // v3  
#define kRepoCommitFormat @"https://api.github.com/repos/%@/%@/commits/%@"                // v3
#define kRepoSearchFormat @"https://github.com/api/v2/json/repos/search/%@"               // v3 not available

// Issues
#define kIssueGithubFormat @"https://github.com/%@/%@/issues/%d"
#define kIssuesFormat @"https://api.github.com/repos/%@/%@/issues?per_page=100&state=%@"           // v3
#define kIssueFormat @"https://api.github.com/repos/%@/%@/issues/%d"                               // v3
#define kIssueOpenFormat @"https://api.github.com/repos/%@/%@/issues"                              // v3
#define kIssueEditFormat @"https://api.github.com/repos/%@/%@/issues/%d"                           // v3
#define kIssueCommentsFormat @"https://api.github.com/repos/%@/%@/issues/%d/comments?per_page=100" // v3

// Organizations
#define kOrganizationGithubFormat @"https://github.com/%@"
#define kOrganizationFeedFormat @"https://github.com/organizations/%@/%@.private.atom"                 // non-API atom
#define kOrganizationFormat @"https://api.github.com/orgs/%@"                                          // v3
#define kOrganizationMembersFormat @"https://api.github.com/orgs/%@/members?per_page=100"              // v3
#define kOrganizationPublicRepositoriesFormat @"https://api.github.com/orgs/%@/repos?per_page=100"     // v3 not announced
#define kOrganizationsRepositoriesFormat @"https://api.github.com/orgs/repos?per_page=100"             // v3 not available

// Issues
#define kIssueStateOpen @"open"
#define kIssueStateClosed @"closed"

// Images
#define kImageGravatarMaxLogicalSize 50

// KVO
#define kResourceLoadingStatusKeyPath @"loadingStatus"
#define kResourceSavingStatusKeyPath @"savingStatus"
#define kUserLoginKeyPath @"login"
#define kUserGravatarKeyPath @"gravatar"
#define kOrganizationLoginKeyPath @"login"
#define kOrganizationGravatarKeyPath @"gravatar"
