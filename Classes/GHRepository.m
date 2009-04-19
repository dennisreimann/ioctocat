#import "GHRepository.h"
#import "GHUser.h"
#import "iOctocatAppDelegate.h"


@implementation GHRepository

@synthesize user, name, owner, descriptionText, githubURL, homepageURL, isPrivate, isFork, forks, watchers, isLoaded, isLoading;

- (id)initWithOwner:(NSString *)theOwner andName:(NSString *)theName {
	if (self = [super init]) {
		self.owner = theOwner;
		self.name = theName;
		self.isLoaded = NO;
		self.isLoading = NO;
	}
	return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHRepository name:'%@' owner:'%@' descriptionText:'%@' githubURL:'%@' homepageURL:'%@' isPrivate:'%@' isFork:'%@' forks:'%d' watchers:'%d'>", name, owner, descriptionText, githubURL, homepageURL, isPrivate ? @"YES" : @"NO", isFork ? @"YES" : @"NO", forks, watchers];
}

- (GHUser *)user {
	iOctocatAppDelegate *appDelegate = (iOctocatAppDelegate *)[[UIApplication sharedApplication] delegate];
	return [appDelegate userWithLogin:owner];
}

- (void)loadRepository {
	self.isLoaded = NO;
	self.isLoading = YES;
	[self performSelectorInBackground:@selector(parseXML) withObject:nil];
}

- (void)parseXML {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *url = [NSString stringWithFormat:kRepoXMLFormat, owner, name];
	NSURL *repoURL = [NSURL URLWithString:url];
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:repoURL];
	[parser setDelegate:self];
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	[parser parse];
	[parser release];
	[pool release];
}

#pragma mark -
#pragma mark NSXMLParser delegation methods

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {	
	string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if (!currentElementValue) {
		currentElementValue = [[NSMutableString alloc] initWithString:string];
	} else {
		[currentElementValue appendString:string];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([elementName isEqualToString:@"name"] || [elementName isEqualToString:@"owner"]) {
		[self setValue:currentElementValue forKey:elementName];
	} else if ([elementName isEqualToString:@"description"]) {
		self.descriptionText = currentElementValue;
	} else if ([elementName isEqualToString:@"url"]) {
		self.githubURL = ([currentElementValue isEqualToString:@""]) ? nil : [NSURL URLWithString:currentElementValue];
	} else if ([elementName isEqualToString:@"homepage"]) {
		self.homepageURL = ([currentElementValue isEqualToString:@""]) ? nil : [NSURL URLWithString:currentElementValue];
	} else if ([elementName isEqualToString:@"fork"]) {
		self.isFork = [currentElementValue boolValue];
	} else if ([elementName isEqualToString:@"private"]) {
		self.isPrivate = [currentElementValue boolValue];
	} else if ([elementName isEqualToString:@"forks"]) {
		self.forks = [currentElementValue integerValue];
	} else if ([elementName isEqualToString:@"watchers"]) {
		self.watchers = [currentElementValue integerValue];
	}
	[currentElementValue release];
	currentElementValue = nil;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	[self performSelectorOnMainThread:@selector(finishedLoading) withObject:nil waitUntilDone:YES];
}

- (void)finishedLoading {
	self.isLoaded = YES;
	self.isLoading = NO;
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[name release];
	[owner release];
	[descriptionText release];
	[githubURL release];
	[homepageURL release];
	[currentElementValue release];
    [super dealloc];
}

@end
