#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHUser;

@interface GHComment : GHResource {
	GHUser *user;
	NSUInteger commentID;
	NSString *body;
	NSDate *created;
	NSDate *updated;
}

@property(nonatomic,retain)GHUser *user;
@property(nonatomic,assign)NSUInteger commentID;
@property(nonatomic,retain)NSString *body;
@property(nonatomic,retain)NSDate *created;
@property(nonatomic,retain)NSDate *updated;

- (void)saveData;
- (void)setUserWithValues:(NSDictionary *)userDict;

@end
