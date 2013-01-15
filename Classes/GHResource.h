#import <Foundation/Foundation.h>


typedef enum {
	GHResourceStatusNotProcessed = 0,
	GHResourceStatusProcessing = 1,
	GHResourceStatusProcessed = 2
} GHResourceStatus;


@class GHAccount;

@interface GHResource : NSObject
@property(nonatomic,strong)NSString *resourcePath;
@property(nonatomic,strong)NSError *error;
@property(nonatomic,readonly)BOOL isLoaded;
@property(nonatomic,readonly)BOOL isLoading;
@property(nonatomic,readonly)BOOL isSaved;
@property(nonatomic,readonly)BOOL isSaving;

- (id)initWithPath:(NSString *)path;
- (void)loadData;
- (void)loadWithParams:(NSDictionary *)params success:(void (^)(GHResource *instance, id data))success failure:(void (^)(GHResource *instance, NSError *error))failure;
- (void)saveWithParams:(NSDictionary *)params path:(NSString *)path method:(NSString *)method success:(void (^)(GHResource *instance, id data))success failure:(void (^)(GHResource *instance, NSError *error))failure;
- (void)needsReload;
- (void)markAsLoaded;
- (void)saveValues:(NSDictionary *)values withPath:(NSString *)path andMethod:(NSString *)method useResult:(void (^)(id response))useResult;
- (void)setHeaderValues:(NSDictionary *)values;
- (void)setValues:(id)response;
- (NSString *)resourceContentType;
- (NSURLRequestCachePolicy)cachePolicy;
@end