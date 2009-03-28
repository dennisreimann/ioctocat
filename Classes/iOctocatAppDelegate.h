#import <UIKit/UIKit.h>


@interface iOctocatAppDelegate : NSObject <UIApplicationDelegate> {
  @private
    IBOutlet UIWindow *window;
    IBOutlet UINavigationController *navigationController;
	BOOL isDataSourceAvailable;
}

@property (nonatomic, readonly) BOOL isDataSourceAvailable;

@end

