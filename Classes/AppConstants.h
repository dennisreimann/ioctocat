// settings
#define kUsernameDefaultsKey @"username"
#define kTokenDefaultsKey @"token"

// tables
#define kStandardCellIdentifier @"StandardCell"
#define kTextCellIdentifier @"TextCell"
#define kLabeledCellIdentifier @"LabeledCell"
#define kFeedEntryCellIdentifier @"FeedEntryCell"
#define kTextCellFontSize 14.0f
#define kTextCellTextLabelTag 1

// URLs
#define kNewsFeedFormat @"https://github.com/%@.private.atom?token=%@"
#define kActivityFeedFormat @"https://github.com/%@.private.actor.atom?token=%@"
#define kUserXMLFormat @"http://github.com/api/v1/xml/%@"

// KVO
#define kFeedLoadingKeyPath @"isLoading"
#define kUserLoadingKeyPath @"isLoading"
#define kUserGravatarImageKeyPath @"gravatar.image"