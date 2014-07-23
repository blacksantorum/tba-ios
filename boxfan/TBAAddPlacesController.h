//
//  TBAAddPlacesController.h
//  boxfan
//
//  Created by Chris Tibbs on 7/1/14.
//  Copyright (c) 2014 Chris Tibbs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBAGooglePlacesClient.h"

@interface TBAAddPlacesController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, TBAGooglePlacesClientDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) CLLocation *location;

@end
