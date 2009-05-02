#import "GHIssuesParserDelegate.h"
#import "GHIssue.h"


@implementation GHIssuesParserDelegate

- (id)initWithTarget:(id)theTarget andSelector:(SEL)theSelector {
	if (self = [super init]) {
        entries = [[NSMutableArray alloc] init];        
		target = theTarget;
		selector = theSelector;
	}
    
	dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";    
	return self;
}

#pragma mark -
#pragma mark NSXMLParser delegation methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:@"issue"]) {
		currentIssue = [[GHIssue alloc] init];
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
	if ([elementName isEqualToString:@"issue"]) {
		[entries addObject:currentIssue];
		[currentIssue release];
		currentIssue = nil;
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
        currentIssue.created = [dateFormatter dateFromString:currentElementValue];
    } else if ([elementName isEqualToString:@"updated-at"]) {        
         currentIssue.updated = [dateFormatter dateFromString:currentElementValue];
        
	}
    
    
	[currentElementValue release];
	currentElementValue = nil;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	DebugLog(@"Parsing error: %@", parseError);
	error = [parseError retain];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	id result = error ? (id)error : (id)entries;
	[target performSelectorOnMainThread:selector withObject:result waitUntilDone:NO];
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[entries release];
    [error release];
	[currentElementValue release];
	[currentIssue release];    
    [dateFormatter release];
    [super dealloc];
}

@end
