#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHUser;

@interface GHComment : GHResource
@property(nonatomic,strong)GHUser *user;
@property(nonatomic,assign)NSUInteger commentID;
@property(nonatomic,strong)NSString *body;
@property(nonatomic,strong)NSDate *created;
@property(nonatomic,strong)NSDate *updated;
@property(nonatomic,readonly)NSString *savePath;

- (void)saveWithParams:(NSDictionary *)values start:(resourceStart)start success:(resourceSuccess)success failure:(resourceFailure)failure;
@end
