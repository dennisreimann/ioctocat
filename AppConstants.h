// Settings
#define kClearAvatarCacheDefaultsKey         @"clearAvatarCache"
#define kLastReadingDateURLDefaultsKeyPrefix @"lastReadingDate:"
#define kLoginDefaultsKey                    @"username"
#define kTokenDefaultsKey                    @"token"
#define kPasswordDefaultsKey                 @"password"
#define kEndpointDefaultsKey                 @"endpoint"
#define kAccountsDefaultsKey                 @"accounts"
#define kLastActivatedDateDefaulsKey         @"lastActivatedDate"

// API
#define kGitHubBaseURL                  @"https://github.com/"
#define kGitHubApiURL                   @"https://api.github.com/"
#define kEnterpriseApiPath              @"api/v3/"
#define kISO8601TimeFormat              @"yyyy-MM-dd'T'HH:mm:ssz"
#define kTokenParamKey                  @"token"
#define kIssueStateOpen                 @"open"
#define kIssueStateClosed               @"closed"
#define kIssueFilterAssigned            @"assigned"
#define kIssueFilterCreated             @"created"
#define kIssueFilterMentioned           @"mentioned"
#define kIssueFilterSubscribed          @"subscribed"
#define kIssueSortCreated               @"created"
#define kIssueSortUpdated               @"updated"
#define kIssueSortComments              @"comments"
#define kResourceLoadingStatusKeyPath   @"loadingStatus"
#define kResourceSavingStatusKeyPath    @"savingStatus"
#define kGravatarKeyPath                @"gravatar"
#define kImageGravatarMaxLogicalSize    50

// Content Types
#define kResourceContentTypeDefault     @"application/vnd.github+json"
#define kResourceContentTypeHTML        @"application/vnd.github.html+json"
#define kResourceContentTypeText        @"application/vnd.github.text+json"
#define kResourceContentTypeFull        @"application/vnd.github.full+json"
#define kResourceContentTypeRaw         @"application/vnd.github.raw+json"

// Tables
#define kRepositoryCellIdentifier       @"RepositoryCell"
#define kFeedEntryCellIdentifier        @"FeedEntryCell"
#define kIssueCellIdentifier            @"IssueCell"
#define kUserCellIdentifier             @"UserCell"
#define kBranchCellIdentifier           @"BranchCell"
#define kCommentCellIdentifier          @"CommentCell"
#define kOrganizationCellIdentifier     @"OrganizationCell"

// Feeds
#define kUserFeedFormat                 @"%@.atom"
#define kUserNewsFeedFormat             @"%@.private.atom"
#define kUserActivityFeedFormat         @"%@.private.actor.atom"
#define kRepoFeedFormat                 @"%@/%@/commits/%@.atom"
#define kOrganizationFeedFormat         @"organizations/%@/%@.private.atom"

// Authenticated user
#define kUserAuthenticatedFormat        @"user"
#define kUserAuthenticatedOrgsFormat    @"user/orgs?per_page=100"
#define kUserAuthenticatedReposFormat   @"user/repos?per_page=100"
#define kUserAuthenticatedIssuesFormat  @"issues?state=%@&filter=%@&sort=%@&per_page=%d"
#define kUserFollowFormat               @"user/following/%@"
#define kRepoWatchFormat                @"user/watched/%@/%@"

// Users
#define kUserOrganizationsFormat        @"users/%@/orgs"
#define kUserFormat                     @"users/%@"
#define kUserReposFormat                @"users/%@/repos?per_page=100"
#define kUserWatchedReposFormat         @"users/%@/watched?per_page=100"
#define kUserFollowingFormat            @"users/%@/following?per_page=100"
#define kUserFollowersFormat            @"users/%@/followers?per_page=100"

// Organizations
#define kOrganizationFormat             @"orgs/%@"
#define kOrganizationMembersFormat      @"orgs/%@/members?per_page=100"
#define kOrganizationRepositoriesFormat @"orgs/%@/repos?per_page=100"

// Repos
#define kRepoFormat                     @"repos/%@/%@"
#define kRepoReadmeFormat               @"repos/%@/%@/readme"
#define kRepoBranchesFormat             @"repos/%@/%@/branches"
#define kRepoForksFormat                @"repos/%@/%@/forks"
#define kRepoCommitsFormat              @"repos/%@/%@/commits"
#define kRepoCommitFormat               @"repos/%@/%@/commits/%@"
#define kRepoCommentsFormat             @"repos/%@/%@/commits/%@/comments?per_page=100"
#define kIssuesFormat                   @"repos/%@/%@/issues?per_page=100&state=%@"
#define kIssueFormat                    @"repos/%@/%@/issues/%d"
#define kIssueOpenFormat                @"repos/%@/%@/issues"
#define kIssueEditFormat                @"repos/%@/%@/issues/%d"
#define kIssueCommentsFormat            @"repos/%@/%@/issues/%d/comments?per_page=100"

// Search
#define kUserSearchFormat               @"legacy/user/search/%@"
#define kRepoSearchFormat               @"legacy/repos/search/%@"
