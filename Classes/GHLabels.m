#import "GHLabels.h"
#import "GHLabel.h"
#import "GHRepository.h"
#import "NSDictionary_IOCExtensions.h"


@interface GHLabels  ()
@property(nonatomic,weak)GHRepository *repository;
@end


@implementation GHLabels

- (id)initWithResourcePath:(NSString *)path {
	self = [super init];
	if (self) {
		self.resourcePath = path;
	}
	return self;
}

- (id)initWithRepository:(GHRepository *)repo {
	NSString *path = [NSString stringWithFormat:kLabelsFormat, repo.owner, repo.name];
	self = [self initWithResourcePath:path];
	if (self) {
		self.repository = repo;
	}
	return self;
}

- (void)setValues:(id)values {
    [super setValues:values];
	for (NSDictionary *dict in values) {
        NSString *name = [dict ioc_stringForKey:@"name"];
		GHLabel *label = [[GHLabel alloc] initWithRepository:self.repository name:name];
		[label setValues:dict];
		[self addObject:label];
	}
}

@end