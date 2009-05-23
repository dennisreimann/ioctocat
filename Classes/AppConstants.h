// Settings
#define kUsernameDefaultsKey @"username"
#define kTokenDefaultsKey @"token"

// API
#define kLoginParamName @"login"
#define kTokenParamName @"token"

// tables
#define kRepositoryCellIdentifier @"RepositoryCell"
#define kFeedEntryCellIdentifier @"FeedEntryCell"
#define kIssueCellIdentifier @"IssueCell"
#define kUserCellIdentifier @"UserCell"
#define kNetworkCellIdentifier @"NetworkCell"

// URLs
#define kUserGithubFormat @"http://github.com/%@"
#define kRepositoryGithubFormat @"http://github.com/%@/%@/tree/master"
#define kIssueGithubFormat @"http://github.com/%@/%@/issues#issue/%d"
#define kUserFeedFormat @"http://github.com/%@.atom"
#define kNewsFeedFormat @"https://github.com/%@.private.atom?token=%@"
#define kActivityFeedFormat @"https://github.com/%@.private.actor.atom?token=%@"
#define kRepoFeedFormat @"http://github.com/feeds/%@/commits/%@/master"
#define kPrivateRepoFeedFormat @"https://github.com/feeds/%@/commits/%@/master"
#define kUserXMLFormat @"https://github.com/api/v2/xml/user/show/%@"
#define kAuthenticateUserXMLFormat @"https://github.com/api/v2/xml/user/show/%@?login=%@&token=%@"
#define kUserReposFormat @"https://github.com/api/v2/xml/repos/show/%@"
#define kUserSearchFormat @"https://github.com/api/v2/xml/user/search/%@"
#define kUserFollowingFormat @"http://github.com/api/v2/json/user/show/%@/following"
#define kUserFollowersFormat @"http://github.com/api/v2/json/user/show/%@/followers"
#define kRepoXMLFormat @"https://github.com/api/v2/xml/repos/show/%@/%@"
#define kRepoSearchFormat @"https://github.com/api/v2/xml/repos/search/%@"
#define kRepoCommitsXMLFormat @"https://github.com/api/v2/xml/commits/list/%@/%@/%@"
#define kRepoWatchFormat @"https://github.com/api/v2/xml/repos/watch/%@/%@?token=%@"
#define kRepoUnwatchFormat @"https://github.com/api/v2/xml/repos/watch/%@/%@?token=%@"
#define kUserFollowFormat @"https://github.com/api/v2/xml/user/follow/%@?token=%@"
#define kUserUnfollowFormat @"https://github.com/api/v2/xml/user/unfollow/%@?token=%@"
#define kRepoIssuesXMLFormat @"http://github.com/api/v2/xml/issues/list/%@/%@/%@"
#define KUserFollowingJSONFormat @"https://github.com/api/v2/json/user/show/%@/following"
#define kNetworksFormat @"http://github.com/api/v2/xml/repos/show/%@/%@/network"
#define kFollowUserFormat @"https://github.com/api/v2/json/user/%@/%@"
#define kWatchRepoFormat @"https://github.com/api/v2/json/repos/%@/%@/%@"
#define kIssueToggleFormat @"https://github.com/api/v2/xml/issues/%@/%@/%@/%d"

// Issues
#define kIssueStateOpen @"open"
#define kIssueStateClosed @"closed"
#define kIssueToggleClose @"close"
#define kIssueToggleReopen @"reopen"

// Following/Watching
#define kFollow @"follow"
#define kUnFollow @"unfollow"
#define kWatch @"watch"
#define kUnWatch @"unwatch"

// KVO
#define kResourceStatusKeyPath @"status"
#define kUserLoginKeyPath @"login"
#define kUserGravatarKeyPath @"gravatar"

// NSCoding
#define kUserPersistenceFileFormat @"%@.plist"
#define kLoginKey @"login"
#define kUserKey @"user"
#define kRepositoriesKey @"repositories"
#define kRepositoriesURLKey @"repositoriesURL"
#define kWatchedRepositoriesKey @"watchedRepositories"
#define kOwnerKey @"owner"
#define kNameKey @"name"

