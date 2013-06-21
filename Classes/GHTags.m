#import "GHTags.h"
#import "GHTag.h"
#import "GHRepository.h"
#import "NSDictionary_IOCExtensions.h"


@interface GHTags ()
@property(nonatomic,strong)GHRepository *repository;
@end


@implementation GHTags

- (id)initWithRepository:(GHRepository *)repo {
	self = [super init];
	if (self) {
		self.repository = repo;
		self.resourcePath = [NSString stringWithFormat:kRepoTagsFormat, self.repository.owner, self.repository.name];
	}
	return self;
}

- (void)setValues:(id)values {
    [super setValues:values];
	for (NSDictionary *dict in values) {
        NSString *sha = [dict ioc_stringForKey:@"sha"];
		GHTag *tag = [[GHTag alloc] initWithRepo:self.repository sha:sha];
		[tag setValues:dict];
		[self addObject:tag];
    }
}

@end
