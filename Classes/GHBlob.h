#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHRepository;

@interface GHBlob : GHResource

@property(nonatomic,retain)GHRepository *repository;
@property(nonatomic,retain)NSString *sha;
@property(nonatomic,retain)NSString *path;
@property(nonatomic,retain)NSString *mode;
@property(nonatomic,retain)NSString *encoding;
@property(nonatomic,retain)NSString *content;
@property(nonatomic,retain)NSData *contentData;
@property(nonatomic,readwrite)NSUInteger size;

+ (id)blobWithRepo:(GHRepository *)theRepo andSha:(NSString *)theSha;
- (id)initWithRepo:(GHRepository *)theRepo andSha:(NSString *)theSha;

@end
