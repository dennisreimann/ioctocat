#import <Foundation/Foundation.h>
#import "GHCollection.h"


@interface GHNotifications : GHCollection
@property(nonatomic,strong)NSDate *lastUpdate;
@property(nonatomic,strong)NSMutableDictionary *byRepository;
@property(nonatomic,readwrite)NSInteger pollInterval;
@end