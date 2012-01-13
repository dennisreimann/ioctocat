// Settings
#define kClearAvatarCacheDefaultsKey @"clearAvatarCache"
#define kLastReadingDateURLDefaultsKeyPrefix @"lastReadingDate:"
#define kLoginDefaultsKey @"username"
#define kPasswordDefaultsKey @"password"

// API
#define kISO8601TimeFormat @"yyyy-MM-dd'T'HH:mm:ssz"

// tables
#define kRepositoryCellIdentifier @"RepositoryCell"
#define kFeedEntryCellIdentifier @"FeedEntryCell"
#define kIssueCellIdentifier @"IssueCell"
#define kUserCellIdentifier @"UserCell"
#define kNetworkCellIdentifier @"NetworkCell"
#define kBranchCellIdentifier @"BranchCell"
#define kCommentCellIdentifier @"CommentCell"
#define kOrganizationCellIdentifier @"OrganizationCell"

// User
#define kUserFeedFormat @"https://github.com/%@.atom" // non-API atom
#define kUserNewsFeedFormat @"https://github.com/%@.private.atom" // non-API atom
#define kUserActivityFeedFormat @"https://github.com/%@.private.actor.atom" // non-API atom
#define kUserGithubFormat @"https://github.com/%@"
#define kUserAuthenticatedFormat @"https://api.github.com/user"            // v3
#define kUserFormat @"https://api.github.com/users/%@"                     // v3
#define kUserAuthenticatedReposFormat @"https://api.github.com/user/repos" // v3
#define kUserReposFormat @"https://api.github.com/users/%@/repos"          // v3
#define kUserWatchedReposFormat @"https://api.github.com/users/%@/watched" // v3
#define kUserFollowingFormat @"https://api.github.com/users/%@/following"  // v3
#define kUserFollowersFormat @"https://api.github.com/users/%@/followers"  // v3
#define kUserFollowFormat @"https://api.github.com/user/following/%@"      // v3
#define kUserSearchFormat @"https://github.com/api/v2/json/user/search/%@"

// Repos
#define kRepoGithubFormat @"https://github.com/%@/%@"
#define kRepoFeedFormat @"https://github.com/feeds/%@/commits/%@/%@"
#define kRepoPrivateFeedFormat @"https://github.com/feeds/%@/commits/%@/%@"
#define kRepoFormat @"https://github.com/api/v2/json/repos/show/%@/%@"
#define kRepoSearchFormat @"https://github.com/api/v2/json/repos/search/%@"
#define kRepoWatchFormat @"https://github.com/api/v2/json/repos/%@/%@/%@"
#define kRepoBranchesFormat @"https://github.com/api/v2/json/repos/show/%@/%@/branches"
#define kRepoNetworkFormat @"https://github.com/api/v2/json/repos/show/%@/%@/network"
#define kRepoPublicCommitsFormat @"https://github.com/api/v2/json/commits/list/%@/%@/%@"
#define kRepoPublicCommitFormat @"https://github.com/api/v2/json/commits/show/%@/%@/%@"
#define kRepoPrivateCommitsFormat @"https://github.com/api/v2/json/commits/list/%@/%@/%@"
#define kRepoPrivateCommitFormat @"https://github.com/api/v2/json/commits/show/%@/%@/%@"

// Issues
#define kIssueFormat @"https://api.github.com/repos/%@/%@/issues/%d" // v3
#define kIssueGithubFormat @"https://github.com/%@/%@/issues/%d"
#define kIssueOpenFormat @"https://github.com/api/v2/json/issues/open/%@/%@"
#define kIssueEditFormat @"https://github.com/api/v2/json/issues/edit/%@/%@/%d"
#define kIssueCommentsFormat @"https://github.com/api/v2/json/issues/comments/%@/%@/%d"
#define kIssueCommentFormat @"https://github.com/api/v2/json/issues/comment/%@/%@/%d"
#define kIssueToggleFormat @"https://github.com/api/v2/json/issues/%@/%@/%@/%d"
#define kIssuesFormat @"https://api.github.com/repos/%@/%@/issues?state=%@" // v3

// Organizations
#define kOrganizationGithubFormat @"https://github.com/%@"
#define kOrganizationFormat @"https://api.github.com/orgs/%@" // v3
#define kOrganizationsFormat @"https://github.com/api/v2/json/user/show/%@/organizations"
#define kOrganizationsRepositoriesFormat @"https://github.com/api/v2/json/organizations/repositories"
#define kOrganizationFeedFormat @"https://github.com/organizations/%@/%@.private.atom"
#define kOrganizationPublicRepositoriesFormat @"https://github.com/api/v2/json/organizations/%@/public_repositories"
#define kOrganizationPublicMembersFormat @"https://github.com/api/v2/json/organizations/%@/public_members"

// Issues
#define kIssueStateOpen @"open"
#define kIssueStateClosed @"closed"
#define kIssueToggleClose @"close"
#define kIssueToggleReopen @"reopen"
#define kIssueTitleParamName @"title"
#define kIssueBodyParamName @"body"
#define kIssueCommentCommentParamName @"comment"

// Images
#define kImageGravatarMaxLogicalSize 50

// Watching
#define kWatch @"watch"
#define kUnWatch @"unwatch"

// KVO
#define kResourceLoadingStatusKeyPath @"loadingStatus"
#define kResourceSavingStatusKeyPath @"savingStatus"
#define kUserLoginKeyPath @"login"
#define kUserGravatarKeyPath @"gravatar"
#define kOrganizationLoginKeyPath @"login"
#define kOrganizationGravatarKeyPath @"gravatar"
