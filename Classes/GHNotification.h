#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHRepository;

@interface GHNotification : GHResource
@property(nonatomic,strong)GHRepository *repository;
@property(nonatomic,strong)NSString *notificationId;
@property(nonatomic,strong)NSDate *updatedAtDate;
@property(nonatomic,strong)NSDate *lastReadAtDate;
@property(nonatomic,strong)NSString *title;
@property(nonatomic,strong)NSString *subjectType;
@property(nonatomic,strong)GHResource *subject;
@property(nonatomic,readonly)BOOL read;

- (id)initWithDict:(NSDictionary *)dict;
- (void)markAsRead;
@end