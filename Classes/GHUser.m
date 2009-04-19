#import "AppConstants.h"
#import "GHUser.h"
#import "GHRepository.h"
#import "Gravatar.h"
#import "GHReposParserDelegate.h"


@interface GHUser (PrivateMethods)

- (void)parseXML;
- (void)parseReposXML;
- (void)finishedLoading;

@end


@implementation GHUser

@synthesize name, login, email, company, blogURL, location, gravatar, repositories, isLoaded, isLoading, isReposLoaded, isReposLoading;

- (id)initWithLogin:(NSString *)theLogin {
	if (self = [super init]) {
		self.login = theLogin;
		self.isLoaded = NO;
		self.isLoading = NO;
		self.isReposLoaded = NO;
		self.isReposLoading = NO;
	}
	return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<GHUser login:'%@' name:'%@' email:'%@' company:'%@' location:'%@' blogURL:'%@'>", login, name, email, company, location, blogURL];
}

#pragma mark -
#pragma mark XML parsing

- (void)loadUser {
	self.isLoaded = NO;
	self.isLoading = YES;
	[self performSelectorInBackground:@selector(parseXML) withObject:nil];
}

- (void)loadRepositories {
	self.isReposLoaded = NO;
	self.isReposLoading = YES;
	[self performSelectorInBackground:@selector(parseReposXML) withObject:nil];
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

- (void)parseReposXML {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *url = [NSString stringWithFormat:kUserReposFormat, login, @""];
	NSURL *reposURL = [NSURL URLWithString:url];
	GHReposParserDelegate *parserDelegate = [[GHReposParserDelegate alloc] initWithTarget:self andSelector:@selector(setRepositories:)];
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:reposURL];
	[parser setDelegate:parserDelegate];
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	[parser parse];
	[parser release];
	[parserDelegate release];
	[pool release];
}

- (void)finishedLoading {
	self.gravatar = self.email ? [Gravatar gravatarWithEmail:self.email andSize:44] : nil;
	self.isLoaded = YES;
	self.isLoading = NO;
}

- (void)setRepositories:(NSArray *)theRepositories {
	[repositories release];
	repositories = [theRepositories retain];
	self.isReposLoaded = YES;
	self.isReposLoading = NO;
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
	// User
	if ([elementName isEqualToString:@"name"] || [elementName isEqualToString:@"company"] || [elementName isEqualToString:@"email"] || [elementName isEqualToString:@"location"]) {
		NSString *value = ([currentElementValue isEqualToString:@""]) ? nil : currentElementValue;
		[self setValue:value forKey:elementName];
	} else if ([elementName isEqualToString:@"blog"]) {
		self.blogURL = ([currentElementValue isEqualToString:@""]) ? nil : [NSURL URLWithString:currentElementValue];
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
    [super dealloc];
}

@end
