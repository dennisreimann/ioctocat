#import "GHComment.h"
#import "GHUser.h"
#import "NSDictionary+Extensions.h"
#import "iOctocat.h"


@implementation GHComment

- (void)setValues:(id)dict {
	self.commentID = [dict safeIntegerForKey:@"id"];
	self.body = [dict safeStringForKey:@"body"];
	self.createdAt = [dict safeDateForKey:@"created_at"];
	self.updatedAt = [dict safeDateForKey:@"updated_at"];
	self.user = [iOctocat.sharedInstance userWithLogin:[dict safeStringForKeyPath:@"user.login"]];
	if (!self.user.gravatarURL) {
		self.user.gravatarURL = [dict safeURLForKeyPath:@"user.avatar_url"];
	}
}

- (BOOL)isNew {
    return !self.commentID ? YES : NO;;
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
    _body = body;
}

#pragma mark Saving

- (void)saveWithParams:(NSDictionary *)params start:(resourceStart)start success:(resourceSuccess)success failure:(resourceFailure)failure {
	[self saveWithParams:params path:self.resourcePath method:kRequestMethodPost start:start success:^(GHResource *instance, id data) {
		[self setValues:data];
		if (success) success(self, data);
	} failure:^(GHResource *instance, NSError *error) {
		if (failure) failure(self, error);
	}];
}

@end
