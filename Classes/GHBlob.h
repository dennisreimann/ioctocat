#import "GHResource.h"


@class GHRepository;

@interface GHBlob : GHResource
@property(nonatomic,strong)GHRepository *repository;
@property(nonatomic,strong)NSString *sha;
@property(nonatomic,strong)NSString *path;
@property(nonatomic,strong)NSString *mode;
@property(nonatomic,strong)NSString *encoding;
@property(nonatomic,strong)NSString *content;
@property(nonatomic,strong)NSString *contentHTML;
@property(nonatomic,strong)NSData *contentData;
@property(nonatomic,strong)NSURL *htmlURL;
@property(nonatomic,assign)NSUInteger size;

- (id)initWithRepo:(GHRepository *)repo path:(NSString *)path ref:(NSString*)ref;
- (BOOL)isMarkdown;
@end