#import "GHReposParserDelegate.h"


@implementation GHReposParserDelegate

- (void)dealloc {
	[currentRepository release];
    [super dealloc];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:@"repository"]) {
		currentRepository = [[GHRepository alloc] init];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([elementName isEqualToString:@"repository"]) {
		// FIXME This is an evil hack to get the feed URL set right
		[currentRepository setOwner:currentRepository.owner andName:currentRepository.name];
		// EMXIF
		currentRepository.status = GHResourceStatusLoaded;
		[resources addObject:currentRepository];
		[currentRepository release];
		currentRepository = nil;
	} else if ([elementName isEqualToString:@"name"]) {
		[currentRepository setValue:currentElementValue forKey:elementName];
	} else if ([elementName isEqualToString:@"username"] || [elementName isEqualToString:@"owner"]) {
		// in the search the owner attribute is called username
		currentRepository.owner = currentElementValue;
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

@end
