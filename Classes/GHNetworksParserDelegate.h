#import <Foundation/Foundation.h>
#import "GHResourcesParserDelegate.h"
#import "GHNetwork.h"


@interface GHNetworksParserDelegate : GHResourcesParserDelegate {
@private
    GHNetwork *currentFork;
}

@end
