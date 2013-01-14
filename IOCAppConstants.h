// Settings
#define kLoginDefaultsKey                    @"username"
#define kAuthIdDefaultsKey                   @"authId"
#define kAuthTokenDefaultsKey                @"authToken"
#define kEndpointDefaultsKey                 @"endpoint"
#define kAccountsDefaultsKey                 @"accounts"
#define kLastActivatedDateDefaulsKey         @"lastActivatedDate"
#define kLineNumbersDefaultsKey              @"lineNumbers"
#define kThemeDefaultsKey                    @"theme"

// API
#define kRequestMethodGet               @"GET"
#define kRequestMethodPut               @"PUT"
#define kRequestMethodPost              @"POST"
#define kRequestMethodPatch             @"PATCH"
#define kRequestMethodDelete            @"DELETE"
#define kGitHubApiURL                   @"https://api.github.com/"
#define kEnterpriseApiPath              @"api/v3/"
#define kIssueStateOpen                 @"open"
#define kIssueStateClosed               @"closed"
#define kIssueFilterAssigned            @"assigned"
#define kIssueFilterCreated             @"created"
#define kIssueFilterMentioned           @"mentioned"
#define kIssueFilterSubscribed          @"subscribed"
#define kResourceLoadingStatusKeyPath   @"loadingStatus"
#define kResourceSavingStatusKeyPath    @"savingStatus"
#define kGravatarKeyPath                @"gravatar"
#define kIssueSortCreated               @"created"
#define kIssueSortUpdated               @"updated"
#define kIssueSortComments              @"comments"

// Content Types
#define kResourceContentTypeDefault     @"application/vnd.github+json"
#define kResourceContentTypeHTML        @"application/vnd.github.html+json"
#define kResourceContentTypeText        @"application/vnd.github.text+json"
#define kResourceContentTypeFull        @"application/vnd.github.full+json"
#define kResourceContentTypeRaw         @"application/vnd.github.raw+json"
#define kResourceContentTypeAtom        @"application/atom+xml"

// Tables
#define kUserObjectCellIdentifier       @"UserObjectCell"
#define kRepositoryCellIdentifier       @"RepositoryCell"
#define kCommentCellIdentifier          @"CommentCell"
#define kCommitCellIdentifier           @"CommitCell"
#define kIssueObjectCellIdentifier      @"IssueObjectCell"

// Events
#define kUserAuthenticatedReceivedEventsFormat  @"users/%@/received_events"
#define kUserAuthenticatedEventsFormat          @"users/%@/events"
#define kUserAuthenticatedOrgEventsFormat       @"users/%@/events/orgs/%@"
#define kUserEventsFormat                       @"users/%@/events/public"
#define kRepoEventsFormat                       @"repos/%@/%@/events"
#define kIssueEventsFormat                      @"repos/%@/%@/issues/events"
#define kOrganizationEventsFormat               @"orgs/%@/events"
#define kNotificationsPath                      @"notifications"

// Authenticated user
#define kAuthorizationsFormat                   @"authorizations"
#define kAuthorizationFormat                    @"authorizations/%@"
#define kUserAuthenticatedFormat                @"user"
#define kUserAuthenticatedOrgsFormat            @"user/orgs?per_page=100"
#define kUserAuthenticatedReposFormat           @"user/repos?per_page=100"
#define kUserAuthenticatedIssuesFormat          @"issues?state=%@&filter=%@&sort=%@&per_page=%d"
#define kUserAuthenticatedGistsFormat           @"gists"
#define kUserAuthenticatedGistsStarredFormat    @"gists/starred"
#define kUserAuthenticatedStarredReposFormat    @"user/starred?per_page=30&sort=pushed"
#define kUserAuthenticatedWatchedReposFormat    @"user/subscriptions?per_page=100"
#define kUserFollowFormat                       @"user/following/%@"
#define kRepoWatchFormat                        @"repos/%@/%@/subscription"
#define kRepoStarFormat                         @"user/starred/%@/%@"

// Gists
#define kGistFormat                     @"gists/%@"
#define kGistStarFormat                 @"gists/%@/star"
#define kUserGistsFormat                @"users/%@/gists"
#define kStarredGistsFormat             @"gists/starred" // not implemented, yet (currently endpoint for gists of authenticated user)
#define kGistCommentsFormat             @"gists/%@/comments"

// Users
#define kUserOrganizationsFormat        @"users/%@/orgs"
#define kUserFormat                     @"users/%@"
#define kUserReposFormat                @"users/%@/repos?per_page=100"
#define kUserStarredReposFormat         @"users/%@/starred?per_page=30&sort=pushed" // only load 30 repos, because these lists tend to be long…
#define kUserWatchedReposFormat         @"users/%@/subscriptions?per_page=100" // @"users/%@/watched?per_page=100"
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
#define kPullRequestsFormat             @"repos/%@/%@/pulls?state=%@"
#define kPullRequestFormat              @"repos/%@/%@/pulls/%d"
#define kPullRequestCommitsFormat       @"repos/%@/%@/pulls/%d/commits"
#define kPullRequestFilesFormat         @"repos/%@/%@/pulls/%d/files"
#define kPullRequestMergeFormat         @"repos/%@/%@/pulls/%d/merge"

// Code
#define kRefFormat                      @"repos/%@/%@/git/refs/%@"
#define kRefsFormat                     @"repos/%@/%@/git/refs"
#define kTagFormat                      @"repos/%@/%@/git/tags/%@"
#define kTagsFormat                     @"repos/%@/%@/git/refs/tags"
#define kBlobFormat                     @"repos/%@/%@/git/blobs/%@"
#define kCommitFormat                   @"repos/%@/%@/git/commits/%@"
#define kTreeFormat                     @"repos/%@/%@/git/trees/%@"
#define kTreeRecursiveFormat            @"repos/%@/%@/git/trees/%@?recursive=1"

// Search
#define kUserSearchFormat               @"legacy/user/search/%@"
#define kRepoSearchFormat               @"legacy/repos/search/%@"
