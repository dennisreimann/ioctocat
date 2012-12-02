#import <UIKit/UIKit.h>


@interface iOctocat ()
@property(nonatomic,strong)NSMutableDictionary *users;
@property(nonatomic,strong)NSMutableDictionary *organizations;

+ (NSString *)gravatarPathForIdentifier:(NSString *)theString;
- (void)clearAvatarCache;
@end