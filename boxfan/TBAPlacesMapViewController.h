//
//  TBAPlacesMapViewController.h
//  boxfan
//
//  Created by Chris Tibbs on 6/30/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "TBAGooglePlacesClient.h"

@interface TBAPlacesMapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, TBAGooglePlacesClientDelegate>

@end
