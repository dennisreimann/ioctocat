#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHRepository;

@interface GHNotification : GHResource
@property(nonatomic,strong)GHRepository *repository;
@property(nonatomic,strong)NSString *notificationId;
@property(nonatomic,strong)NSDate *updatedAtDate;
@property(nonatomic,strong)NSDate *lastReadAtDate;
@property(nonatomic,strong)NSString *title;
@property(nonatomic,readwrite)BOOL isUnread;

- (id)initWithId:(NSString *)gistId;
@end