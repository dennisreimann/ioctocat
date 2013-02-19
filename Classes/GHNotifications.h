#import <Foundation/Foundation.h>
#import "GHCollection.h"


@class GHNotification;

@interface GHNotifications : GHCollection
@property(nonatomic,strong)NSDate *lastUpdate;
@property(nonatomic,readwrite)NSInteger pollInterval;
@property(nonatomic,readonly)NSInteger unreadCount;
@property(nonatomic,readonly)BOOL canReload;

- (void)markAsRead:(GHNotification *)notification success:(resourceSuccess)success failure:(resourceFailure)failure;
- (void)markAllAsReadSuccess:(resourceSuccess)success failure:(resourceFailure)failure;
- (void)markAllAsReadForRepoId:(NSString *)repoId success:(resourceSuccess)success failure:(resourceFailure)failure;
@end