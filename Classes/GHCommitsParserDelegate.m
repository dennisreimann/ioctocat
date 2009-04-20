#import "GHCommitsParserDelegate.h"
#import "GHCommit.h"


@implementation GHCommitsParserDelegate

- (id)initWithTarget:(id)theTarget andSelector:(SEL)theSelector {
	if (self = [super init]) {
		commits = [[NSMutableArray alloc] init];
		target = theTarget;
		selector = theSelector;
	}
	return self;
}

#pragma mark -
#pragma mark NSXMLParser delegation methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:@"commit"]) {
		currentCommit = [[GHCommit alloc] init];
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
	if ([elementName isEqualToString:@"commit"]) {
		[commits addObject:currentCommit];
		[currentCommit release];
		currentCommit = nil;
	} else if ([elementName isEqualToString:@"message"] || [elementName isEqualToString:@"tree"]) {
		[currentCommit setValue:currentElementValue forKey:elementName];
	} else if ([elementName isEqualToString:@"id"]) {
		currentCommit.commitID = currentElementValue;
	} else if ([elementName isEqualToString:@"url"]) {
		currentCommit.commitURL = ([currentElementValue isEqualToString:@""]) ? nil : [NSURL URLWithString:currentElementValue];
	}
	[currentElementValue release];
	currentElementValue = nil;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	[target performSelectorOnMainThread:selector withObject:commits waitUntilDone:YES];
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[commits release];
	[currentElementValue release];
	[currentCommit release];
    [super dealloc];
}

@end
