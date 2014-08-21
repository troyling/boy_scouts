//
//  NHSCDonationMapLocationViewController.m
//  Boy Scouts
//
//  Created by Troy Ling on 5/17/14.
//  Copyright (c) 2014 Daniel Webster Council Boy Scouts of America. All rights reserved.
//

#import "NHSCDonationMapLocationViewController.h"
#import "NHSCPlaceAnnotation.h"
#import "NHSCAddressHelper.h"
#import "NHSCDonationDetailsViewController.h"
#import "NHSCAlertViewHelper.h"

@interface NHSCDonationMapLocationViewController ()

@end

@implementation NHSCDonationMapLocationViewController

@synthesize region;
@synthesize currentLocation;
bool isDonationViewInitialized = NO; // flag indicating if the map view has been initialized
double RANGE = 0.20f; // delta used to specidy the range of which range the current location

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
    
    // set itself to be the delegate of the map view
    self.mapView.delegate = self;
    
    // initialize current location if necessary
    if (!currentLocation) {
        currentLocation = [self.mapView userLocation];
        region = MKCoordinateRegionMakeWithDistance(currentLocation.location.coordinate, 500, 500);
        [self.mapView setRegion:region animated:NO];
    }
    
    // sets the annotaions
    [self displayAnnotations];
}

/*
 * Finds the nearby locations that have record for the popcorn
 */
- (void)displayAnnotations {
    
    // remove all annocations
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    // Find locations around from backend
    PFQuery *query = [PFQuery queryWithClassName:@"FoodDonationVisits"];
    
    // specify a range to search for the database
    double latitudeUpperBound = currentLocation.location.coordinate.latitude + RANGE;
    double latitudeLowerBound = currentLocation.location.coordinate.latitude - RANGE;
    double longitudeUpperBound = currentLocation.location.coordinate.longitude + RANGE;
    double longitudeLowerBound = currentLocation.location.coordinate.longitude - RANGE;
    
    // add query constraints
    query.limit = 1000;
    [query whereKey:@"latitude" greaterThanOrEqualTo:@(latitudeLowerBound)];
    [query whereKey:@"latitude" lessThanOrEqualTo:@(latitudeUpperBound)];
    [query whereKey:@"longitude" greaterThanOrEqualTo:@(longitudeLowerBound)];
    [query whereKey:@"longitude" lessThanOrEqualTo:@(longitudeUpperBound)];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *visits, NSError *error) {
        if (!error) {
            // populate the visits to the view
            // Do something with the found objects
            for (PFObject *visit in visits) {
                double latitude = [visit[@"latitude"] doubleValue];
                double longitude = [visit[@"longitude"] doubleValue];
                NSString *title = visit[@"address"];
                
                // creates annotation
                CLLocationCoordinate2D visitCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
                
                NHSCPlaceAnnotation *pin = [[NHSCPlaceAnnotation alloc] init];
                pin.coordinate = visitCoordinate;
                pin.title = title;
                
                // adds annotation to the map
                [self.mapView addAnnotation:pin];
            }
        } else {
            // error
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            [[NHSCAlertViewHelper getNetworkErrorAlertView] show];
        }
    }];
    
}

// center the user's current location in the map view
- (IBAction)locateButtonClicked:(id)sender {
    region = MKCoordinateRegionMakeWithDistance(currentLocation.location.coordinate, 500, 500);
    [self.mapView setRegion:region animated:YES];
}

/*
 * stores the food pickup location for future pickup
 */
- (IBAction)pickButtonClicked:(id)sender {
    // check if location is null;
    if (currentLocation == nil) {
        // handle this properly
        return;
    }
    
    // latitude and longtitude
    NSNumber *latitude = [NSNumber numberWithDouble: currentLocation.location.coordinate.latitude];
    NSNumber *longtitude = [NSNumber numberWithDouble: currentLocation.location.coordinate.longitude];
    
    // get the formatted address from Google
    NSString *address = [NHSCAddressHelper getAddressFromLatLon:currentLocation.location.coordinate.latitude withLongitude:currentLocation.location.coordinate.longitude];
    
    // query to see if the location has been stored
    if (address != nil) {
        PFQuery *query = [PFQuery queryWithClassName:@"FoodDonationVisits"];
        [query whereKey:@"address" equalTo:address];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *visits, NSError *error) {
            if (!error) {
                // The find succeeded.
                if (visits.count == 0) {
                    // no previous entry is in the database.
                    // save new data to database
                    PFObject *visit = [PFObject objectWithClassName:@"FoodDonationVisits"];
                    visit[@"latitude"] = latitude;
                    visit[@"longitude"] = longtitude;
                    visit[@"address"] = address;
                    [visit saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if(succeeded) {
                            // creates annotation and updates the view
                            CLLocationCoordinate2D visitCoordinate = CLLocationCoordinate2DMake(currentLocation.location.coordinate.latitude, currentLocation.location.coordinate.longitude);
                            
                            NHSCPlaceAnnotation *pin = [[NHSCPlaceAnnotation alloc] init];
                            pin.coordinate = visitCoordinate;
                            pin.title = address;
                            
                            // adds annotation to the map
                            [self.mapView addAnnotation:pin];
                        }
                    }];
                } else {
                    // do nothing
                }
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
                [[NHSCAlertViewHelper getNetworkErrorAlertView] show];
            }
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MapView Delegate Methods

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    // store the user location
    currentLocation = userLocation;
    
    if (!isDonationViewInitialized) {
        region = MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 500, 500);
        [mapView setRegion:region animated:NO];
        
        // This is temporarily placed here, since the location is being updated inside the function
        [self displayAnnotations];
        
        isDonationViewInitialized = YES;
    }
    
    
    // remove us as delegate so we don't re-center map each time user moves
    //mapView.delegate = nil;
}

/*
 * customize annotation
 */
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(NHSCPlaceAnnotation*)annotation {
    if([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    static NSString *identifier = @"myAnnotation";
    MKPinAnnotationView * annotationView = (MKPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (!annotationView)
    {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        annotationView.animatesDrop = NO;
        annotationView.canShowCallout = YES;
    }else {
        annotationView.annotation = annotation;
    }
    
    // set the color of the pin
    annotationView.pinColor = MKPinAnnotationColorPurple;
    
    // adds button to the annotation
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    return annotationView;
}

/*
 * Open the detail view for the selected annotation
 */
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    [self performSegueWithIdentifier:@"showDonationDetails" sender:view];
}


 #pragma mark - Navigation
 
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"showDonationDetails"]) {
        
        // get the associated annotation
        MKAnnotationView *view = (MKAnnotationView *)sender;
        NHSCPlaceAnnotation *pin = view.annotation;
        
        // Get the new view controller using [segue destinationViewController].
        NHSCDonationDetailsViewController *dest = [segue destinationViewController];
        
        // Pass the selected object to the new view controller.
        dest.annotation = pin;
        dest.parent = self;
        
    }
}


@end
