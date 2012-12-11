#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHUser;

@interface GHComment : GHResource
@property(nonatomic,readonly)GHUser *user;
@property(nonatomic,assign)NSUInteger commentID;
@property(nonatomic,strong)NSString *userLogin;
@property(nonatomic,strong)NSString *body;
@property(nonatomic,strong)NSDate *created;
@property(nonatomic,strong)NSDate *updated;

- (void)saveData;
- (void)setUserWithValues:(NSDictionary *)userDict;
@end
