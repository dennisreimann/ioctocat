#import "GHBranches.h"
#import "GHBranch.h"
#import "GHRepository.h"
#import "NSDictionary_IOCExtensions.h"


@interface GHBranches ()
@property(nonatomic,weak)GHRepository *repository;
@end


@implementation GHBranches

- (id)initWithRepository:(GHRepository *)repo {
	self = [super init];
	if (self) {
		self.repository = repo;
		self.resourcePath = [NSString stringWithFormat:kRepoBranchesFormat, self.repository.owner, self.repository.name];
	}
	return self;
}

- (void)setValues:(id)values {
    [super setValues:values];
	for (NSDictionary *dict in values) {
        NSString *name = [dict ioc_stringForKey:@"name"];
		GHBranch *branch = [[GHBranch alloc] initWithRepository:self.repository andName:name];
		[branch setValues:dict];
		if ([branch.name isEqualToString:self.repository.mainBranch]) {
			[self insertObject:branch atIndex:0];
		} else {
			[self addObject:branch];
		}
    }
}

@end
