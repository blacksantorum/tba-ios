//
//  TBAPlacesMapViewController.m
//  boxfan
//
//  Created by Chris Tibbs on 6/30/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import "TBAPlacesMapViewController.h"
#import "TBAAddPlacesController.h"
#import "TBAGooglePlacesClient.h"

#define kGOOGLE_API_KEY @"AIzaSyCtifPaaVKXvTGV05I7guqsXRDvPdingEI"

@interface TBAPlacesMapViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSArray *placeResults;

@end

@implementation TBAPlacesMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self;
    
    // Ensure that you can view your own location in the map view.
    [self.mapView setShowsUserLocation:YES];
    
    //Instantiate a location object.
    self.locationManager = [[CLLocationManager alloc] init];
    
    //Make this controller the delegate for the location manager.
    [self.locationManager setDelegate:self];
    
    //Set some parameters for the location object.
    [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    
    [[TBAGooglePlacesClient sharedClient] fetchResultsForKeyword:@"Abbey Tavern" atLocation:self.locationManager.location withDelegate:self];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showPlacesSearch"]) {
        if ([segue.destinationViewController isKindOfClass:[TBAAddPlacesController class]]) {
            ((TBAAddPlacesController *)segue.destinationViewController).location = self.locationManager.location;
        }
    }
}

#pragma mark TBAGooglePlacesDelegate

- (void)TBAGooglePlacesClient:(TBAGooglePlacesClient *)client didUpdateWithPlaces:(id)places
{
    NSLog(@"%@", places);
}

- (void)TBAGooglePlacesClient:(TBAGooglePlacesClient *)client didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
}

#pragma mark - MKMapViewDelegate methods.
- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views {
    MKCoordinateRegion region;
    region = MKCoordinateRegionMakeWithDistance(self.locationManager.location.coordinate,1000,1000);
    
    
    [mv setRegion:region animated:YES];
}


@end
