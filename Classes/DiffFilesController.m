#import "DiffFilesController.h"
#import "CodeController.h"


@interface DiffFilesController ()
@property(nonatomic,retain)NSArray *files;
@end


@implementation DiffFilesController

@synthesize files;

- (id)initWithFiles:(NSArray *)theFiles {
    [super initWithNibName:@"Files" bundle:nil];
	self.files = theFiles;
    return self;
}

- (void)dealloc {
    [files release], files = nil;
    [super dealloc];
}

#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    return (files.count == 0) ? 1 : files.count;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    }
	if (files.count == 0) {
		cell.textLabel.text = @"No files";
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
	} else {
		NSDictionary *fileInfo = [files objectAtIndex:indexPath.row];
		NSString *patch =  [fileInfo objectForKey:@"patch"];
		cell.textLabel.text = [fileInfo objectForKey:@"filename"];
		cell.selectionStyle = patch ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleNone;
		cell.accessoryType = patch ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
	}
    return cell;
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (files.count == 0) return;
	id fileInfo = [files objectAtIndex:indexPath.row];
	if ([fileInfo isKindOfClass:[NSDictionary class]]) {
		CodeController *codeController = [CodeController controllerWithFiles:files currentIndex:indexPath.row];
		[self.navigationController pushViewController:codeController animated:YES];
	}
}

#pragma mark Autorotation

- (BOOL)shouldAutorotate {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return [self shouldAutorotate];
}

@end

