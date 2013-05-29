#import "GHCollection.h"


@class GHRepository;

@interface GHEvents : GHCollection
@property(nonatomic,strong)NSDate *lastUpdate;

- (id)initWithPath:(NSString *)path account:(GHAccount *)account;
- (id)initWithRepository:(GHRepository *)repo;
@end