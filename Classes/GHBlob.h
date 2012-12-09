#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHRepository;

@interface GHBlob : GHResource

@property(nonatomic,strong)GHRepository *repository;
@property(nonatomic,strong)NSString *sha;
@property(nonatomic,strong)NSString *path;
@property(nonatomic,strong)NSString *mode;
@property(nonatomic,strong)NSString *encoding;
@property(nonatomic,strong)NSString *content;
@property(nonatomic,strong)NSData *contentData;
@property(nonatomic,assign)NSUInteger size;

- (id)initWithRepo:(GHRepository *)theRepo andSha:(NSString *)theSha;

@end