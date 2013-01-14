#import "IOCDefaultsPersistenceTests.h"
#import "IOCDefaultsPersistence.h"


@interface IOCDefaultsPersistenceTests ()
@property(nonatomic,strong)NSDate *date;
@property(nonatomic,strong)NSUserDefaults *defaults;
@end


@implementation IOCDefaultsPersistenceTests

- (void)setUp {
    [super setUp];
	self.date = [NSDate date];
	self.defaults = [NSUserDefaults standardUserDefaults];
}

- (void)testLastUpdateForPathWhenUnset {
	expect([IOCDefaultsPersistence lastUpdateForPath:@"user"]).to.equal(nil);
}

- (void)testLastUpdateForPath {
	[self.defaults setValue:self.date forKey:@"lastReadingDate:user/orgs"];
	[self.defaults synchronize];
	expect([IOCDefaultsPersistence lastUpdateForPath:@"user/orgs"]).to.equal(self.date);
}

- (void)testSetLastUpateForPath {
	[IOCDefaultsPersistence setLastUpate:self.date forPath:@"user/repos"];
	expect([self.defaults objectForKey:@"lastReadingDate:user/repos"]).to.equal(self.date);
}

@end