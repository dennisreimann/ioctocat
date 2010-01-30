#import "NetworksController.h"
#import "GHNetwork.h"
#import "GHNetworks.h"
#import "RepositoryController.h"


@implementation NetworksController

@synthesize repository;

- (id)initWithRepository:(GHRepository *)theRepository {
    [super initWithNibName:@"Networks" bundle:nil];
	self.title = @"Forks";
    self.repository = theRepository;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [repository.networks addObserver:self forKeyPath:kResourceLoadingStatusKeyPath options:NSKeyValueObservingOptionNew context:nil];
	if (![self.currentNetworks isLoaded]) [self.currentNetworks loadNetworks];
}

- (void)dealloc {
    [loadingNetworksCell release];
    [noNetworksCell release];
    [networkCell release];    
    [super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:kResourceLoadingStatusKeyPath]) {
		[self.tableView reloadData];
		GHNetworks *theNetworks = (GHNetworks *)object;
		if (!theNetworks.isLoading && theNetworks.error) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loading error" message:@"Could not load the network graph" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return ( self.currentNetworks.isLoading ) || (self.currentNetworks.entries.count == 0) ? 1 : self.currentNetworks.entries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.currentNetworks.isLoading) return loadingNetworksCell;
	if (self.currentNetworks.entries.count == 0) return noNetworksCell;
  	NetworkCell *cell = (NetworkCell *)[tableView dequeueReusableCellWithIdentifier:kNetworkCellIdentifier];
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"NetworkCell" owner:self options:nil];
		cell = networkCell;
	}
	cell.network = [self.currentNetworks.entries objectAtIndex:indexPath.row];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	GHNetwork *network = [self.currentNetworks.entries objectAtIndex:indexPath.row];
	GHRepository *networkRepository = network.repository;
    RepositoryController *repoController = [[RepositoryController alloc] initWithRepository:networkRepository];
    [self.navigationController pushViewController:repoController animated:YES];
    [repoController release];    
}

- (GHNetworks *)currentNetworks {
   return  repository.networks;
}

@end
