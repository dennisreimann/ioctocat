#import "GHUsersParserDelegate.h"
#import "GHUser.h"


@implementation GHUsersParserDelegate

- (id)initWithTarget:(id)theTarget andSelector:(SEL)theSelector {
	[super init];
	users = [[NSMutableArray alloc] init];
	target = theTarget;
	selector = theSelector;
	return self;
}

#pragma mark -
#pragma mark NSXMLParser delegation methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:@"user"]) {
		currentUser = [[GHUser alloc] init];
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
	if ([elementName isEqualToString:@"user"]) {
		currentUser.status = GHResourceStatusLoaded;
		[users addObject:currentUser];
		[currentUser release];
		currentUser = nil;
	} else if ([elementName isEqualToString:@"name"] && !currentUser.name) {
		currentUser.name = currentElementValue;
	} else if ([elementName isEqualToString:@"login"] || [elementName isEqualToString:@"company"] || [elementName isEqualToString:@"email"] || [elementName isEqualToString:@"location"]) {
		NSString *value = ([currentElementValue isEqualToString:@""]) ? nil : currentElementValue;
		[currentUser setValue:value forKey:elementName];
	} else if ([elementName isEqualToString:@"public-gist-count"]) {
		currentUser.publicGistCount = [currentElementValue integerValue];
	} else if ([elementName isEqualToString:@"private-gist-count"]) {
		currentUser.privateGistCount = [currentElementValue integerValue];
	} else if ([elementName isEqualToString:@"public-repo-count"]) {
		currentUser.publicRepoCount = [currentElementValue integerValue];
	} else if ([elementName isEqualToString:@"total-private-repo-count"]) {
		currentUser.privateRepoCount = [currentElementValue integerValue];
	} else if ([elementName isEqualToString:@"blog"]) {
		currentUser.blogURL = ([currentElementValue isEqualToString:@""]) ? nil : [NSURL URLWithString:currentElementValue];
	}
	[currentElementValue release];
	currentElementValue = nil;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	DebugLog(@"Parsing error: %@", parseError);
	error = [parseError retain];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	id result = error ? (id)error : (id)users;
	[target performSelectorOnMainThread:selector withObject:result waitUntilDone:NO];
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[error release];
	[users release];
	[currentUser release];
	[currentElementValue release];
    [super dealloc];
}

@end
