#import "GHResourcesParserDelegate.h"


@implementation GHResourcesParserDelegate

- (id)initWithTarget:(id)theTarget andSelector:(SEL)theSelector {
	[super init];
	target = theTarget;
	selector = theSelector;
	return self;
}

#pragma mark -
#pragma mark NSXMLParser delegation methods

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	resources = [[NSMutableArray alloc] init];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {	
	string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if (!currentElementValue) {
		currentElementValue = [[NSMutableString alloc] initWithString:string];
	} else {
		[currentElementValue appendString:string];
	}
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	DebugLog(@"Parsing error: %@", parseError);
	error = [parseError retain];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	id result = error ? (id)error : (id)resources;
	[target performSelectorOnMainThread:selector withObject:result waitUntilDone:YES];
	[resources release];
	resources = nil;
}


#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[error release];
	[resources release];
	[currentElementValue release];
    [super dealloc];
}

@end
