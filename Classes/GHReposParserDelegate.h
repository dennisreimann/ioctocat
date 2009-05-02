#import <Foundation/Foundation.h>
#import "GHResourcesParserDelegate.h"
#import "GHRepository.h"


@interface GHReposParserDelegate : GHResourcesParserDelegate {
  @private
	GHRepository *currentRepository;
}

@end
