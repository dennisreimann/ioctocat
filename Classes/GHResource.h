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
- (void)needsReload;
- (void)saveValues:(NSDictionary *)values withPath:(NSString *)path andMethod:(NSString *)method useResult:(void (^)(id response))useResult;
- (void)setValues:(id)response;
- (NSString *)resourceContentType;
@end