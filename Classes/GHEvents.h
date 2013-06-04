#import "GHCollection.h"


@class GHRepository;

@interface GHEvents : GHCollection
@property(nonatomic,strong)NSDate *lastUpdate;
@property(nonatomic,strong)NSDate *lastRead;

- (id)initWithPath:(NSString *)path account:(GHAccount *)account;
- (id)initWithRepository:(GHRepository *)repo;
- (void)markAllAsRead;
@end