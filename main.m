#import <UIKit/UIKit.h>


int main(int argc, char *argv[]) {
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int retVal = UIApplicationMain(argc, argv, @"GHApplication", nil);
	[pool release];
	return retVal;
}