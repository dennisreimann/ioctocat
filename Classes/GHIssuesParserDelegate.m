#import "GHIssuesParserDelegate.h"
#import "iOctocat.h"


@implementation GHIssuesParserDelegate

@synthesize repository;

- (void)dealloc {
	[repository release], repository = nil;
	[currentIssue release], currentIssue = nil;
	
    [super dealloc];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:@"issue"]) {
		currentIssue = [[GHIssue alloc] initWithRepository:repository];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([elementName isEqualToString:@"issue"]) {
		[resources addObject:currentIssue];
		[currentIssue release], currentIssue = nil;
	} else if ([elementName isEqualToString:@"user"]) {
		currentIssue.user = currentElementValue;        
	} else if ([elementName isEqualToString:@"title"]) {
		currentIssue.title = currentElementValue;
	} else if ([elementName isEqualToString:@"body"]) {
		currentIssue.body = currentElementValue;
	} else if ([elementName isEqualToString:@"state"]) {
		currentIssue.state = currentElementValue;
	} else if ([elementName isEqualToString:@"votes"]) {
		currentIssue.votes = [currentElementValue integerValue];
	} else if ([elementName isEqualToString:@"number"]) {
		currentIssue.num = [currentElementValue integerValue];
    } else if ([elementName isEqualToString:@"created-at"]) {        
        currentIssue.created = [iOctocat parseDate:currentElementValue];
    } else if ([elementName isEqualToString:@"updated-at"]) {        
         currentIssue.updated = [iOctocat parseDate:currentElementValue];
	}
	[currentElementValue release], currentElementValue = nil;
}

@end
