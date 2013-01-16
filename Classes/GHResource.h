#import <Foundation/Foundation.h>


@class GHAccount, GHResource;

typedef enum {
	GHResourceStatusNotProcessed = 0,
	GHResourceStatusProcessing = 1,
	GHResourceStatusProcessed = 2
} GHResourceStatus;

typedef void (^resourceSuccess)(GHResource *instance, id data);
typedef void (^resourceFailure)(GHResource *instance, NSError *error);

@interface GHResource : NSObject
@property(nonatomic,strong)NSString *resourcePath;
@property(nonatomic,strong)NSError *error;
@property(nonatomic,readonly)BOOL isLoaded;
@property(nonatomic,readonly)BOOL isLoading;
@property(nonatomic,readonly)BOOL isSaved;
@property(nonatomic,readonly)BOOL isSaving;

- (id)initWithPath:(NSString *)path;
- (void)needsReload;
- (void)markAsLoaded;
- (void)setHeaderValues:(NSDictionary *)values;
- (void)setValues:(id)response;
- (NSString *)resourceContentType;
- (NSURLRequestCachePolicy)cachePolicy;

// FIXME: This is the old interface used all over the app.
// Please use the new one underneath in the future!
- (void)loadData;
- (void)saveValues:(NSDictionary *)values withPath:(NSString *)path andMethod:(NSString *)method useResult:(void (^)(id response))useResult;

// TODO: Use new interface throughout the app
- (void)loadWithParams:(NSDictionary *)params success:(resourceSuccess)success failure:(resourceFailure)failure;
- (void)saveWithParams:(NSDictionary *)values path:(NSString *)path method:(NSString *)method success:(resourceSuccess)success failure:(resourceFailure)failure;
@end