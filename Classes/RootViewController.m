#import "AppConstants.h"
#import "RootViewController.h"
#import "WebViewController.h"
#import "iOctocatAppDelegate.h"
#import "GHFeed.h"
#import "GHFeedEntry.h"
#import "GHFeedEntryCell.h"


@interface RootViewController (PrivateMethods)

- (void)startParsingFeed;
- (void)parseFeed;
- (void)addEntryToFeed:(GHFeedEntry *)anEntry;
- (void)finishedParsingFeed;
- (GHFeedEntryCell *)feedEntryCellFromNib;

@end


@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"My GitHub News Feed";
	UIBarButtonItem *loadingView = [[UIBarButtonItem alloc] initWithCustomView:activityView];
	self.navigationItem.rightBarButtonItem = loadingView;
	[loadingView release];
	// Load the feed
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *username = [defaults stringForKey:kUsernameDefaultsKey];
	NSString *token = [defaults stringForKey:kTokenDefaultsKey];
	NSString *url = [NSString stringWithFormat:@"https://github.com/%@.private.atom?token=%@", username, token];
	NSURL *feedURL = [NSURL URLWithString:url];
	feed = [[GHFeed alloc] initWithURL:feedURL];
	dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss"; // ISO8601
	[self startParsingFeed];
}

- (void)startParsingFeed {
	[activityView startAnimating];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[self performSelectorInBackground:@selector(parseFeed) withObject:nil];
}

- (void)parseFeed {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:feed.url];
	[parser setDelegate:self];
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	[parser parse];
	[parser release];
	[pool release];
}

- (void)addEntryToFeed:(GHFeedEntry *)anEntry {
	[feed.entries addObject:anEntry];
}

- (void)finishedParsingFeed {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[activityView stopAnimating];
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return feed.entries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GHFeedEntryCell *cell = (GHFeedEntryCell *)[tableView dequeueReusableCellWithIdentifier:kFeedEntryCellIdentifier];
    if (cell == nil) {
        cell = [self feedEntryCellFromNib];
    }
	GHFeedEntry *entry = [feed.entries objectAtIndex:indexPath.row];
	[cell setEntry:entry];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GHFeedEntry *entry = [feed.entries objectAtIndex:indexPath.row];
	WebViewController *webController = [[WebViewController alloc] initWithURL:entry.linkURL];
	webController.title = entry.title;
	[self.navigationController pushViewController:webController animated:YES];
	[webController release];
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 50.0f;
}

#pragma mark -
#pragma mark NSXMLParser delegation methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:@"entry"]) {
		currentEntry = [[GHFeedEntry alloc] init];
	} else if ([elementName isEqualToString:@"link"]) {
		NSString *url = [attributeDict valueForKey:@"href"];
		currentEntry.linkURL = ([url isEqualToString:@""]) ? nil : [NSURL URLWithString:url];
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {	
	if (!currentElementValue) {
		string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		currentElementValue = [[NSMutableString alloc] initWithString:string];
	} else {
		string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
		[currentElementValue appendString:string];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([elementName isEqualToString:@"entry"]) {
		[self performSelectorOnMainThread:@selector(addEntryToFeed:) withObject:currentEntry waitUntilDone:NO];
		[currentEntry release];
		currentEntry = nil;
	} else if ([elementName isEqualToString:@"id"]) {
		NSString *value = [currentElementValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		NSString *event = [value substringFromIndex:20];
		currentEntry.entryID = value;
		if ([event hasPrefix:@"Fork"]) {
			currentEntry.eventType = @"fork";
		} else if ([event hasPrefix:@"CommitComment"]) {
			currentEntry.eventType = @"comment";
		} else if ([event hasPrefix:@"Watch"]) {
			currentEntry.eventType = @"watch";
		} else if ([event hasPrefix:@"Create"]) {
			currentEntry.eventType = @"create";
		} else if ([event hasPrefix:@"ForkApply"]) {
			currentEntry.eventType = @"merge";
		} else if ([event hasPrefix:@"Push"]) {
			currentEntry.eventType = @"push";
		} else if ([event hasPrefix:@"Wiki"]) {
			currentEntry.eventType = @"wiki";
		} else {
			currentEntry.eventType = nil;
		}
	} else if ([elementName isEqualToString:@"updated"]) {
		currentEntry.date = [dateFormatter dateFromString:currentElementValue];
	} else if ([elementName isEqualToString:@"title"] || [elementName isEqualToString:@"content"]) {
		[currentEntry setValue:currentElementValue forKey:elementName];
	} else if ([elementName isEqualToString:@"name"]) {
		currentEntry.authorName = currentElementValue;
	} 
	[currentElementValue release];
	currentElementValue = nil;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	[self finishedParsingFeed];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	#ifdef DEBUG
	NSLog(@"Parsing error: %@", [parseError localizedDescription]);
	#endif
	// Let's just assume it's an authentication error
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Authentication error" message:@"Please revise the settings and check your username and API token" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

#pragma mark -
#pragma mark Helpers

- (GHFeedEntryCell *)feedEntryCellFromNib {
	NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"GHFeedEntryCell" owner:self options:nil];
	NSEnumerator *nibEnumerator = [nibContents objectEnumerator];
	NSObject *nibItem = nil;
	GHFeedEntryCell *cell = nil;
	while ((nibItem = [nibEnumerator nextObject]) != nil) {
		if ([nibItem isKindOfClass:[GHFeedEntryCell class]]) {
			cell = (GHFeedEntryCell *)nibItem;
			if ([cell.reuseIdentifier isEqualToString:kFeedEntryCellIdentifier]) {
				break;
			} else {
				cell = nil;
			}
		}
	}
	return cell;
}

#pragma mark -
#pragma mark Cleanup

- (void)dealloc {
	[activityView release];
	[dateFormatter release];
	[currentElementValue release];
	[currentEntry release];
	[feed release];
    [super dealloc];
}


@end

