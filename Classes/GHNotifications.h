#import <Foundation/Foundation.h>
#import "GHCollection.h"


@class GHNotification;

@interface GHNotifications : GHCollection
@property(nonatomic,strong)NSDate *lastUpdate;
@property(nonatomic,strong)NSMutableDictionary *byRepository;
@property(nonatomic,readwrite)NSInteger pollInterval;
@property(nonatomic,readwrite)NSInteger notificationsCount;

- (void)markAsRead:(GHNotification *)notification success:(resourceSuccess)success failure:(resourceFailure)failure;
- (void)markAllAsReadSuccess:(resourceSuccess)success failure:(resourceFailure)failure;
@end