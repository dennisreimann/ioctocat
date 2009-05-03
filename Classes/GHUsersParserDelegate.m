#import "GHUsersParserDelegate.h"


@implementation GHUsersParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:@"user"]) {
		currentUser = [[GHUser alloc] init];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([elementName isEqualToString:@"user"]) {
		currentUser.status = GHResourceStatusLoaded;
		[resources addObject:currentUser];
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
	} else if ([elementName isEqualToString:@"plan"]) {
		// FIXME This is not the best way to verify that,
		// but the API does not offer a better solution yet
		currentUser.isAuthenticated = YES;
	}
	[currentElementValue release];
	currentElementValue = nil;
}

- (void)dealloc {
	[currentUser release];
    [super dealloc];
}

@end
