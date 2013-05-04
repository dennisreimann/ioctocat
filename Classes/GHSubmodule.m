#import "GHResource.h"
#import "GHSubmodule.h"
#import "GHRepository.h"
#import "NSString+Extensions.h"
#import "NSDictionary+Extensions.h"


@implementation GHSubmodule

- (id)initWithRepo:(GHRepository *)repo sha:(NSString *)sha {
	self = [super init];
	if (self) {
		self.repository = repo;
		self.sha = sha;
		self.resourcePath = [NSString stringWithFormat:kTreeFormat, self.repository.owner, self.repository.name, [self.sha stringByEscapingForURLArgument]];
	}
	return self;
}

#pragma mark Loading

- (void)setValues:(id)values {
	self.sha = [values safeStringForKey:@"sha"];
	self.path = [values safeStringForKey:@"path"];
	self.name = [values safeStringOrNilForKey:@"name"];
	if (!self.name) self.name = self.path;
}

@end