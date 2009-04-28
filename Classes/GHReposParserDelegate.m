#import "GHReposParserDelegate.h"
#import "GHRepository.h"


@implementation GHReposParserDelegate

- (id)initWithTarget:(id)theTarget andSelector:(SEL)theSelector {
	if (self = [super init]) {
		repositories = [[NSMutableArray alloc] init];
		target = theTarget;
		selector = theSelector;
	}
	return self;
}

#pragma mark -
#pragma mark NSXMLParser delegation methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:@"repository"]) {
		currentRepository = [[GHRepository alloc] init];
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
	if ([elementName isEqualToString:@"repository"]) {
		// FIXME This is an evil hack to get the feed URL set right
		[currentRepository setOwner:currentRepository.owner andName:currentRepository.name];
		// EMXIF
		currentRepository.status = GHResourceStatusLoaded;
		[repositories addObject:currentRepository];
		[currentRepository release];
		currentRepository = nil;
	} else if ([elementName isEqualToString:@"name"] || [elementName isEqualToString:@"owner"]) {
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

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	DebugLog(@"Parsing error: %@", parseError);
	error = [parseError retain];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	id result = error ? (id)error : (id)repositories;
	[target performSelectorOnMainThread:selector withObject:result waitUntilDone:NO];
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[error release];
	[repositories release];
	[currentElementValue release];
	[currentRepository release];
    [super dealloc];
}

@end
