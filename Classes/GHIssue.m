#import "GHIssue.h"
#import "GHIssueComment.h"
#import "GHIssueComments.h"
#import "GHRepository.h"
#import "GHMilestone.h"
#import "GHLabels.h"
#import "GHUser.h"
#import "iOctocat.h"
#import "GHFMarkdown.h"
#import "NSURL_IOCExtensions.h"
#import "NSString+Emojize.h"
#import "NSString_IOCExtensions.h"
#import "NSDictionary_IOCExtensions.h"


@interface GHIssue ()
@property(nonatomic,strong)NSMutableAttributedString *attributedBody;
@end


@implementation GHIssue

- (id)initWithRepository:(GHRepository *)repo {
	self = [super init];
	if (self) {
		self.repository = repo;
		self.state = kIssueStateOpen;
	}
	return self;
}

- (BOOL)isNew {
	return !self.number ? YES : NO;
}

- (BOOL)isOpen {
	return [self.state isEqualToString:kIssueStateOpen];
}

- (NSString *)resourcePath {
    if (self.isNew) {
		return [NSString stringWithFormat:kIssueOpenFormat, self.repository.owner, self.repository.name];
	} else {
		return [NSString stringWithFormat:kIssueFormat, self.repository.owner, self.repository.name, self.number];
	}
}

- (NSString *)repoIdWithIssueNumber {
	return [NSString stringWithFormat:@"%@#%d", self.repository.repoId, self.number];
}

- (NSURL *)htmlURL {
    if (!_htmlURL) {
        self.htmlURL = [NSURL ioc_URLWithFormat:@"/%@/%@/issues/%d", self.repository.owner, self.repository.name, self.number];
    }
    return _htmlURL;
}

- (NSMutableAttributedString *)attributedBody {
    if (!_attributedBody) {
        NSString *text = self.body;
        text = [text emojizedString];
        _attributedBody = [text ghf_ghf_mutableAttributedStringFromGHFMarkdownWithContextRepoId:self.repository.repoId];
    }
    return _attributedBody;
}

- (GHIssueComments *)comments {
    if (!_comments) {
        _comments = [[GHIssueComments alloc] initWithParent:self];
    }
    return _comments;
}

- (GHLabels *)labels {
    if (!_labels) {
        _labels = [[GHLabels alloc] initWithRepository:self.repository];
    }
    return _labels;
}

#pragma mark Loading

- (void)setValues:(id)dict {
	NSString *userLogin = [dict ioc_stringForKeyPath:@"user.login"];
	NSString *assigneeLogin = [dict ioc_stringForKeyPath:@"assignee.login"];
	self.user = [iOctocat.sharedInstance userWithLogin:userLogin];
	self.assignee = [iOctocat.sharedInstance userWithLogin:assigneeLogin];
	self.createdAt = [dict ioc_dateForKey:@"created_at"];
	self.updatedAt = [dict ioc_dateForKey:@"updated_at"];
	self.closedAt = [dict ioc_dateForKey:@"closed_at"];
	self.title = [dict ioc_stringForKey:@"title"];
	self.body = [dict ioc_stringForKey:@"body"];
	self.state = [dict ioc_stringForKey:@"state"];
	self.number = [dict ioc_integerForKey:@"number"];
	self.htmlURL = [dict ioc_URLForKey:@"html_url"];
    // repo
	if (!self.repository) {
		NSString *owner = [dict ioc_stringForKeyPath:@"repository.owner.login"];
		NSString *name = [dict ioc_stringForKeyPath:@"repository.name"];
		if (![owner ioc_isEmpty] && ![name ioc_isEmpty]) {
			self.repository = [[GHRepository alloc] initWithOwner:owner andName:name];
		}
	}
    // labels
    NSArray *labels = [dict ioc_arrayForKey:@"labels"];
    if (labels) {
        self.labels = [[GHLabels alloc] initWithRepository:self.repository];
        [self.labels setValues:labels];
    }
    // milestone
    NSDictionary *milestoneDict = [dict ioc_dictForKey:@"milestone"];
    if (milestoneDict) {
        self.milestone = [[GHMilestone alloc] initWithRepository:self.repository];
        [self.milestone setValues:milestoneDict];
    }
}

@end