#import "GHUsersParserDelegate.h"


@implementation GHUsersParserDelegate

- (void)dealloc {
    [currentUser release];
    [super dealloc];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:@"user"]) {
		currentUser = [[GHUser alloc] init];
	} else if ([elementName isEqualToString:@"plan"]) {
		isParsingPlan = YES;
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([elementName isEqualToString:@"user"]) {
		currentUser.loadingStatus = GHResourceStatusProcessed;
		[resources addObject:currentUser];
		[currentUser release];
		currentUser = nil;
	} else if ([elementName isEqualToString:@"gravatar-id"]) {
		currentUser.gravatarHash = currentElementValue;
	} else if (([elementName isEqualToString:@"name"] || [elementName isEqualToString:@"fullname"]) && !isParsingPlan) {
		// in the search the name attribute is called fullname
		currentUser.name = currentElementValue;
	} else if ([elementName isEqualToString:@"login"] || [elementName isEqualToString:@"username"]) {
		// in the search the login attribute is called username
		currentUser.login = currentElementValue;
	} else if ([elementName isEqualToString:@"company"] || [elementName isEqualToString:@"email"] || [elementName isEqualToString:@"location"]) {
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
		// This is not the best way to verify authentication
		// but the API does not offer a better solution yet
		currentUser.isAuthenticated = YES;
		isParsingPlan = NO;
	}
	[currentElementValue release];
	currentElementValue = nil;
}

@end
