#import "GHCollection.h"


@class GHNotification;

@interface GHNotifications : GHCollection
@property(nonatomic,strong)NSDate *lastUpdate;
@property(nonatomic,readwrite)NSInteger pollInterval;
@property(nonatomic,readonly)NSInteger unreadCount;
@property(nonatomic,readonly)BOOL canReload;

- (void)markAsRead:(GHNotification *)notification start:(resourceStart)start success:(resourceSuccess)success failure:(resourceFailure)failure;
- (void)markAllAsReadStart:(resourceStart)start success:(resourceSuccess)success failure:(resourceFailure)failure;
- (void)markAllAsReadForRepoId:(NSString *)repoId start:(resourceStart)start success:(resourceSuccess)success failure:(resourceFailure)failure;
@end