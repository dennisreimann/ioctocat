#import "GHCollection.h"
#import "NSURL_IOCExtensions.h"


@interface GHCollection ()
@property(nonatomic,assign)BOOL resetItemsOnLoad;
@end


@implementation GHCollection

- (id)init {
	self = [super init];
	if (self) {
		self.items = [NSMutableArray array];
        self.nextPageURL = nil;
        self.resetItemsOnLoad = NO;
	}
	return self;
}

- (void)setHeaderValues:(NSDictionary *)headers {
    [self setNextPageURLFromResponseHeaders:headers];
}

- (void)setNextPageURLFromResponseHeaders:(NSDictionary *)headers {
    NSURL *nextPageURL = nil;
    NSString *link = headers[@"Link"];
    if (link) {
        NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"<(.+)>; rel=\"next\"" options:NSRegularExpressionCaseInsensitive error:NULL];
        NSTextCheckingResult *match = [regex firstMatchInString:link options:NSMatchingReportCompletion range:NSMakeRange(0, link.length)];
        if (match && match.range.location != NSNotFound) {
            NSString *nextPage = [link substringWithRange:[match rangeAtIndex:1]];
            nextPageURL = [NSURL URLWithString:nextPage];
        }
    }
    self.nextPageURL = nextPageURL;
}

- (void)setValues:(id)response {
    if (self.resetItemsOnLoad) {
        [self.items removeAllObjects];
    }
}

#pragma mark Enumarable

- (NSUInteger)count {
	return self.items.count;
}

- (BOOL)isEmpty {
	return self.count == 0;
}

- (BOOL)hasNextPage {
	return self.nextPageURL != nil;
}

- (NSUInteger)indexOfObject:(id)object {
	return [self.items indexOfObject:object];
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx {
	return self.items[idx];
}

- (BOOL)containsObject:(id)object {
	return [self.items containsObject:object];
}

- (void)addObject:(id)object {
	[self.items addObject:object];
}

- (void)removeObject:(id)object {
	[self.items removeObject:object];
}

- (void)insertObject:(id)object atIndex:(NSUInteger)idx {
	[self.items insertObject:object atIndex:idx];
}

#pragma mark API

- (void)loadNextWithStart:(resourceStart)start success:(resourceSuccess)success failure:(resourceFailure)failure {
    self.resetItemsOnLoad = NO;
    [super loadWithParams:[self.nextPageURL ioc_queryDictionary] path:self.nextPageURL.path method:kRequestMethodGet start:start success:success failure:failure];
}

- (void)loadWithParams:(NSDictionary *)params path:(NSString *)path method:(NSString *)method start:(resourceStart)start success:(resourceSuccess)success failure:(resourceFailure)failure {
    self.resetItemsOnLoad = YES;
    [super loadWithParams:params path:path method:method start:start success:success failure:failure];
}

- (void)saveObject:(GHResource *)object params:(NSDictionary *)params start:(resourceStart)start success:(resourceSuccess)success failure:(resourceFailure)failure {
    BOOL newItem = object.isNew;
    [object saveWithParams:params start:start success:^(GHResource *instance, id data) {
        if (newItem) [self addObject:instance];
        [self markAsChanged];
        if (success) success(self, data);
    } failure:failure];
}

- (void)deleteObject:(GHResource *)object start:(resourceStart)start success:(resourceSuccess)success failure:(resourceFailure)failure {
    [object deleteWithStart:start success:^(GHResource *instance, id data) {
        [self removeObject:instance];
        [self markAsChanged];
        if (success) success(self, data);
    } failure:failure];
}

@end
