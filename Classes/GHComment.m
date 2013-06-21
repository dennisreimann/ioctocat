#import "GHComment.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "GHFMarkdown.h"
#import "NSString+Emojize.h"
#import "NSDictionary_IOCExtensions.h"
#import "iOctocat.h"


@implementation GHComment

- (void)setValues:(id)dict {
	self.commentID = [dict ioc_integerForKey:@"id"];
	self.body = [dict ioc_stringForKey:@"body"];
	self.createdAt = [dict ioc_dateForKey:@"created_at"];
	self.updatedAt = [dict ioc_dateForKey:@"updated_at"];
	self.user = [iOctocat.sharedInstance userWithLogin:[dict ioc_stringForKeyPath:@"user.login"]];
	if (!self.user.gravatarURL) {
		self.user.gravatarURL = [dict ioc_URLForKeyPath:@"user.avatar_url"];
	}
}

- (GHRepository *)repository {
    return _repository;
}

- (BOOL)isNew {
    return !self.commentID ? YES : NO;
}

- (NSString *)bodyWithoutEmailFooter {
    if (!_bodyWithoutEmailFooter) {
        NSString *text = self.body;
        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"On .+ wrote:\\s?" options:NSRegularExpressionCaseInsensitive error:NULL];
        NSTextCheckingResult *match = [regex firstMatchInString:text options:NSMatchingReportCompletion range:NSMakeRange(0, text.length)];
        if (!match || match.range.location == NSNotFound) {
            _bodyWithoutEmailFooter = text;
        } else {
            _bodyWithoutEmailFooter = [[text substringToIndex:match.range.location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }
    return _bodyWithoutEmailFooter;
}

- (void)setBody:(NSString *)body {
    _bodyWithoutEmailFooter = nil;
    _attributedBody = nil;
    _body = body;
}

- (NSMutableAttributedString *)attributedBody {
    if (!_attributedBody) {
        NSString *text = self.bodyWithoutEmailFooter;
        text = [text emojizedString];
        _attributedBody = [text ghf_ghf_mutableAttributedStringFromGHFMarkdownWithContextRepoId:self.repository.repoId];
    }
    return _attributedBody;
}

@end
