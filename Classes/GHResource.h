#import <Foundation/Foundation.h>


@class GHAccount, GHResource;

typedef enum {
	GHResourceStatusFailed   = -1,
	GHResourceStatusUnloaded =  0,
	GHResourceStatusLoading  =  1,
	GHResourceStatusLoaded   =  2,
	GHResourceStatusChanged  =  3
} GHResourceStatus;

typedef void (^resourceStart)(GHResource *instance);
typedef void (^resourceSuccess)(GHResource *instance, id data);
typedef void (^resourceFailure)(GHResource *instance, NSError *error);

@interface GHResource : NSObject
@property(nonatomic,strong)NSString *resourcePath;
@property(nonatomic,strong)NSError *error;
@property(nonatomic,readonly)BOOL isEmpty;
@property(nonatomic,readonly)BOOL isFailed;
@property(nonatomic,readonly)BOOL isUnloaded;
@property(nonatomic,readonly)BOOL isLoaded;
@property(nonatomic,readonly)BOOL isLoading;
@property(nonatomic,readonly)BOOL isChanged;

- (id)initWithPath:(NSString *)path;
- (void)markAsUnloaded;
- (void)markAsLoaded;
- (void)markAsChanged;
- (void)setHeaderValues:(NSDictionary *)values;
- (void)setValues:(id)response;
//- (void)loadWithParams:(NSDictionary *)params success:(resourceSuccess)success failure:(resourceFailure)failure;
- (void)loadWithParams:(NSDictionary *)params start:(resourceStart)start success:(resourceSuccess)success failure:(resourceFailure)failure;
- (void)loadWithParams:(NSDictionary *)params path:(NSString *)path method:(NSString *)method start:(resourceStart)start success:(resourceSuccess)success failure:(resourceFailure)failure;
- (void)saveWithParams:(NSDictionary *)values path:(NSString *)path method:(NSString *)method start:(resourceStart)start success:(resourceSuccess)success failure:(resourceFailure)failure;
- (NSString *)resourceContentType;
@end