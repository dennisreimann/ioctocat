@class GHResource;

@protocol IOCResourceEditingDelegate <NSObject>
- (BOOL)canManageResource:(GHResource *)resource;
@optional
- (void)savedResource:(GHResource *)resource;
- (void)editResource:(GHResource *)resource;
- (void)deleteResource:(GHResource *)resource;
@end