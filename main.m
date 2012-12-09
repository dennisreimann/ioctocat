#import <UIKit/UIKit.h>
#import "IOCApplication.h"


int main(int argc, char *argv[]) {
	@autoreleasepool {
		int retVal = UIApplicationMain(argc, argv, NSStringFromClass(IOCApplication.class), nil);
		return retVal;
	}
}