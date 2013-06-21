#import "IOCResourceDrafts.h"


@implementation IOCResourceDrafts

+ (NSDictionary *)draftForKey:(NSString *)key {
    return [self.drafts objectForKey:key];
}

+ (void)saveDraft:(NSDictionary *)draft forKey:(NSString *)key {
    [self.drafts setObject:draft forKey:key];
}

+ (void)flush {
    [self.drafts removeAllObjects];
}

+ (NSMutableDictionary *)drafts {
    static NSMutableDictionary *_drafts = nil;
    if (!_drafts) {
        _drafts = [NSMutableDictionary dictionary];
    }
    return _drafts;
}

@end