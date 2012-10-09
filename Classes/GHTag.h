#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHRepository, GHCommit;

@interface GHTag : GHResource

@property(nonatomic,retain)GHRepository *repository;
@property(nonatomic,retain)GHCommit *commit;
@property(nonatomic,retain)NSString *sha;
@property(nonatomic,retain)NSString *tag;
@property(nonatomic,retain)NSString *message;
@property(nonatomic,retain)NSString *taggerName;
@property(nonatomic,retain)NSString *taggerEmail;
@property(nonatomic,retain)NSDate *taggerDate;

+ (id)tagWithRepo:(GHRepository *)theRepo andSha:(NSString *)theSha;
- (id)initWithRepo:(GHRepository *)theRepo andSha:(NSString *)theSha;

@end
