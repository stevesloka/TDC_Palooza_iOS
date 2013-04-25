//
//  WhereamiViewController.m
//  Whereami
//
//  Created by joeconway on 7/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "WhereamiViewController.h"
#import "BNRMapPoint.h"

@implementation WhereamiViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        locationManager = [[CLLocationManager alloc] init];        
        [locationManager setDelegate:self];        
        [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        
       
        
    }
    return self;
}
- (void)viewDidLoad
{
    [worldView setShowsUserLocation:YES];
    
    // --- Load map locations ---
    
    // [Natrona Heights]
    CLLocationCoordinate2D coord_NatronaHeights = CLLocationCoordinate2DMake(40.624865,-79.723256);
    CLLocationCoordinate2D coord_Presby = CLLocationCoordinate2DMake(40.442603,-79.960384);
    CLLocationCoordinate2D coord_Robinson = CLLocationCoordinate2DMake(40.452172,-80.160713);
    
    // [Add the points onto the map
    [self addPointToMap:coord_NatronaHeights title:@"Natrona Heights"];
    [self addPointToMap:coord_Presby title:@"Presby"];
    [self addPointToMap:coord_Robinson title:@"Robinson"];
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)tf
{
    // This method isn't implemented yet - but will be soon.
    [self findLocation];
    
    [tf resignFirstResponder];
    
    return YES;
}
- (void)findLocation
{
    [locationManager startUpdatingLocation];
    [activityIndicator startAnimating];
    [locationTitleField setHidden:YES];
}

-(void)addPointToMap:(CLLocationCoordinate2D)coord title:(NSString *)title
{
    // Create an instance of MapPoint with the current data
    BNRMapPoint *mp = [[BNRMapPoint alloc] initWithCoordinate:coord
                                                        title:title];
    // Add it to the map view
    [worldView addAnnotation:mp];
    
    // Zoom the region to this location
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, 9900, 9900);
    [worldView setRegion:region animated:YES];
    
    [locationTitleField setText:@""];
}

- (void)foundLocation:(CLLocation *)loc
{
    CLLocationCoordinate2D coord = [loc coordinate];
    
    // Create an instance of MapPoint with the current data
    BNRMapPoint *mp = [[BNRMapPoint alloc] initWithCoordinate:coord
                                                  title:[locationTitleField text]];
    // Add it to the map view 
    [worldView addAnnotation:mp];
        
    // Zoom the region to this location
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, 9900, 9900);
    [worldView setRegion:region animated:YES];
    
    [locationTitleField setText:@"My Location"];
    [activityIndicator stopAnimating];
    [locationTitleField setHidden:NO];
    [locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    // How many seconds ago was this new location created?
    NSTimeInterval t = [[newLocation timestamp] timeIntervalSinceNow];
    
    // CLLocationManagers will return the last found location of the 
    // device first, you don't want that data in this case.
    // If this location was made more than 3 minutes ago, ignore it.
    if (t < -180) {
        // This is cached data, you don't want it, keep looking
        return;
    }
    
    [self foundLocation:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"Could not find location: %@", error);
}

- (void)mapView:(MKMapView *)mv didUpdateUserLocation:(MKUserLocation *)u
{
    CLLocationCoordinate2D loc = [u coordinate];
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(loc, 9900, 9900);
    [worldView setRegion:region animated:YES];
}

- (void)dealloc
{
    // Tell the location manager to stop sending us messages
    [locationManager setDelegate:nil];
}
@end
