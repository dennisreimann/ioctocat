// settings
#define kUsernameDefaultsKey @"username"
#define kTokenDefaultsKey @"token"

// tables
#define kStandardCellIdentifier @"StandardCell"
#define kRepositoryCellIdentifier @"RepositoryCell"
#define kTextCellIdentifier @"TextCell"
#define kLabeledCellIdentifier @"LabeledCell"
#define kFeedEntryCellIdentifier @"FeedEntryCell"

// URLs
#define kNewsFeedFormat @"https://github.com/%@.private.atom?token=%@"
#define kActivityFeedFormat @"https://github.com/%@.private.actor.atom?token=%@"
#define kUserXMLFormat @"https://github.com/api/v2/xml/user/show/%@"
#define kUserReposFormat @"https://github.com/api/v2/xml/repos/show/%@?token=%@"
#define kRepoXMLFormat @"https://github.com/api/v2/xml/repos/show/%@/%@"

// KVO
#define kFeedLoadingKeyPath @"isLoading"
#define kUserLoadingKeyPath @"isLoading"
#define kUserReposLoadingKeyPath @"isReposLoading"
#define kUserGravatarImageKeyPath @"gravatar.image"