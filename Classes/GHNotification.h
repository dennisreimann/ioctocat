#import "GHResource.h"


@class GHRepository;

@interface GHNotification : GHResource
@property(nonatomic,strong)GHRepository *repository;
@property(nonatomic,strong)GHResource *subject;
@property(nonatomic,strong)NSDate *updatedAt;
@property(nonatomic,strong)NSDate *lastReadAt;
@property(nonatomic,strong)NSString *title;
@property(nonatomic,strong)NSString *subjectType;
@property(nonatomic,readwrite)NSInteger notificationId;
@property(nonatomic,readonly)BOOL read;

- (id)initWithDict:(NSDictionary *)dict;
- (id)initWithNotificationId:(NSInteger)notificationId;
- (void)markAsReadStart:(resourceStart)start success:(resourceSuccess)success failure:(resourceFailure)failure;
@end