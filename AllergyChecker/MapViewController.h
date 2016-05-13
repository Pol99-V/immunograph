//
//  MapViewController.h
//  AllergyChecker
//
//  Created by PRAGE on 2015/09/14.
//  Copyright (c) 2015年 prage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ResultViewController.h"

@class MapViewController;

@protocol MapViewDelegate <NSObject>
@optional
- (void) setLocation:(CLLocationCoordinate2D)location;
@end


@interface MapViewController : UIViewController<MKMapViewDelegate, CLLocationManagerDelegate>

@property CLLocationManager *locationManager;

@property (strong, nonatomic) IBOutlet UILabel *lblLocation;

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

- (IBAction)btnOK:(id)sender;
- (IBAction)btnClear:(id)sender;
- (void)setMapLocation:(CLLocationCoordinate2D) location;

@property (nonatomic, weak) id<MapViewDelegate> delegate;

@end