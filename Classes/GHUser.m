#import "AppConstants.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "Gravatar.h"


@interface GHUser (PrivateMethods)

- (void)parseXML;
- (void)finishedLoading;

@end


@implementation GHUser

@synthesize name, login, email, company, blogURL, location, gravatar, repositories, isLoaded, isLoading;

- (id)initWithLogin:(NSString *)theLogin {
	if (self = [super init]) {
		self.login = theLogin;
		self.repositories = [NSMutableArray array];
		self.isLoaded = NO;
		self.isLoading = NO;
		self.gravatar = [Gravatar gravatarWithEmail:self.email andSize:44];
	}
	return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHUser login:'%@' name:'%@' email:'%@' company:'%@' location:'%@' blogURL:'%@'>", login, name, email, company, location, blogURL];
}

#pragma mark -
#pragma mark XML parsing

- (void)loadDetails {
	self.isLoaded = NO;
	self.isLoading = YES;
	[self performSelectorInBackground:@selector(parseXML) withObject:nil];
}

- (void)parseXML {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *url = [NSString stringWithFormat:kUserXMLFormat, login];
	NSURL *userURL = [NSURL URLWithString:url];
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:userURL];
	[parser setDelegate:self];
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	[parser parse];
	[parser release];
	[pool release];
}

- (void)finishedLoading {
	self.gravatar = [Gravatar gravatarWithEmail:self.email andSize:44];
	self.isLoaded = YES;
	self.isLoading = NO;
}

#pragma mark -
#pragma mark NSXMLParser delegation methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:@"repositories"]) {
		self.repositories = [NSMutableArray array];
	} else if ([elementName isEqualToString:@"repository"]) {
		currentRepository = [[GHRepository alloc] init];
		currentRepository.user = self;
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {	
	string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if (!currentElementValue) {
		currentElementValue = [[NSMutableString alloc] initWithString:string];
	} else {
		[currentElementValue appendString:string];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	// User
	if ((!currentRepository && [elementName isEqualToString:@"name"]) || [elementName isEqualToString:@"company"] || [elementName isEqualToString:@"email"] || [elementName isEqualToString:@"location"]) {
		NSString *value = ([currentElementValue isEqualToString:@""]) ? nil : currentElementValue;
		[self setValue:value forKey:elementName];
	} else if ([elementName isEqualToString:@"blog"]) {
		self.blogURL = ([currentElementValue isEqualToString:@""]) ? nil : [NSURL URLWithString:currentElementValue];
	} 
	// Repositories
	else if ([elementName isEqualToString:@"repository"]) {
		[repositories addObject:currentRepository];
		[currentRepository release];
		currentRepository = nil;
	} else if ([elementName isEqualToString:@"name"]) {
		[currentRepository setValue:currentElementValue forKey:elementName];
	} else if ([elementName isEqualToString:@"description"]) {
		currentRepository.descriptionText = currentElementValue;
	} else if ([elementName isEqualToString:@"url"]) {
		currentRepository.githubURL = ([currentElementValue isEqualToString:@""]) ? nil : [NSURL URLWithString:currentElementValue];
	} else if ([elementName isEqualToString:@"homepage"]) {
		currentRepository.homepageURL = ([currentElementValue isEqualToString:@""]) ? nil : [NSURL URLWithString:currentElementValue];
	} else if ([elementName isEqualToString:@"fork"]) {
		currentRepository.isFork = [currentElementValue boolValue];
	} else if ([elementName isEqualToString:@"private"]) {
		currentRepository.isPrivate = [currentElementValue boolValue];
	} else if ([elementName isEqualToString:@"forks"]) {
		currentRepository.forks = [currentElementValue integerValue];
	} else if ([elementName isEqualToString:@"watchers"]) {
		currentRepository.watchers = [currentElementValue integerValue];
	}
	[currentElementValue release];
	currentElementValue = nil;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	[self performSelectorOnMainThread:@selector(finishedLoading) withObject:nil waitUntilDone:NO];
}

#ifdef DEBUG
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	NSLog(@"Parsing error: %@", [parseError localizedDescription]);
}
#endif

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[name release];
	[login release];
	[email release];
	[company release];
	[blogURL release];
	[location release];
	[gravatar release];
	[repositories release];
	[currentElementValue release];
	[currentRepository release];
    [super dealloc];
}

@end
