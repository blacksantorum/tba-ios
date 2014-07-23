//
//  TBAAddPlacesController.m
//  boxfan
//
//  Created by Chris Tibbs on 7/1/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import "TBAAddPlacesController.h"
#import "Place.h"
#import <MapKit/MapKit.h>
#import "User.h"
#import "BoxFanRevealController.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>

@interface TBAAddPlacesController ()

@property (nonatomic, strong) NSArray *placeResults;
@property (nonatomic, strong) MKLocalSearchRequest *request;

@property (nonatomic, strong) User *loggedInUser;

@property (nonatomic, strong) Place *pendingPlace;

@end

@implementation TBAAddPlacesController

-(User *)loggedInUser
{
    BoxFanRevealController *bfrc= (BoxFanRevealController *)self.revealController;
    return bfrc.loggedInUser;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.request = [[MKLocalSearchRequest alloc] init];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.placeResults count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MKMapItem *item = self.placeResults[indexPath.row];
    NSLog(@"%@",item.placemark.addressDictionary);
    self.pendingPlace = [[Place alloc] initWithMKMapItem:item];
 
    [[[UIAlertView alloc] initWithTitle:@"Add place?" message:[NSString stringWithFormat:@"Add %@?",self.pendingPlace.name] delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil] show];
    
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        self.pendingPlace = nil;
    }
    else {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSDictionary *parameters = @{@"name":self.pendingPlace.name, @"address":self.pendingPlace.address, @"city":self.pendingPlace.city, @"state":self.pendingPlace.state, @"zipcode":self.pendingPlace.zip};
        [manager POST:[URLS urlStringForPostingPlace:self.pendingPlace] parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"%@",responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //[self setNetworkActivityIndicatorVisible:NO];
        }];

    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MKMapItem *item = self.placeResults[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Places Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Places Cell"];
    }
    cell.textLabel.text = item.name;
    cell.detailTextLabel.text = [self printedAddressForItem:item];
    
    return cell;

}

- (NSString *)printedAddressForItem:(MKMapItem *)item
{
    NSLog(@"Name: %@, Dictionary: %@", item.name, item.placemark.addressDictionary);
    
    NSString *street = item.placemark.addressDictionary[@"Street"];
    NSString *city = item.placemark.addressDictionary[@"City"];
    NSString *state = item.placemark.addressDictionary[@"State"];
    
    return [NSString stringWithFormat:@"%@%@%@",
            street ? [street stringByAppendingString:@", "]: @"",
            city ? [city stringByAppendingString:@", "]: @"",
            state ? state : @""];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    self.request.naturalLanguageQuery = searchString;
    self.request.region = MKCoordinateRegionMakeWithDistance(self.location.coordinate, 15000, 15000);
    
    MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:self.request];
    
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        [self applyLocationResults:response];
    }];
    
    return YES;
}

- (void)applyLocationResults:(MKLocalSearchResponse *)response
{
    self.placeResults = response.mapItems;
    [self.searchDisplayController.searchResultsTableView reloadData];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
