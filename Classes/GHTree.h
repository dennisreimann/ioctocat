#import <Foundation/Foundation.h>
#import "GHResource.h"


@class GHRepository;

@interface GHTree : GHResource

@property(nonatomic,retain)GHRepository *repository;
@property(nonatomic,retain)NSString *sha;
@property(nonatomic,retain)NSString *path;
@property(nonatomic,retain)NSString *mode;
@property(nonatomic,retain)NSMutableArray *trees;
@property(nonatomic,retain)NSMutableArray *blobs;

+ (id)treeWithRepo:(GHRepository *)theRepo andSha:(NSString *)theSha;
- (id)initWithRepo:(GHRepository *)theRepo andSha:(NSString *)theSha;

@end