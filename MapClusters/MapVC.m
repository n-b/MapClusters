#import "MapVC.h"
@import MapKit;
#import "StationsStore.h"
#import "Station.h"

// Clusterers
#import "CCHMapClusterController.h"
#import "CCHMapClusterAnnotation.h"

@interface MapVC() <MKMapViewDelegate>
@property IBOutlet MKMapView * mapView;
@property (nonatomic) CCHMapClusterController *mapClusterController;
@property (nonatomic) StationsStore * store;
@end

@implementation MapVC

- (CCHMapClusterController *)mapClusterController
{
    if(!_mapClusterController && self.viewLoaded) {
        _mapClusterController = [[CCHMapClusterController alloc] initWithMapView:self.mapView];
    }
    return _mapClusterController;
}
- (StationsStore *) store
{
    if(!_store) {
        NSURL * url = [[NSBundle bundleForClass:self.class] URLForResource:@"stations" withExtension:@"csv"];
        _store =  [[StationsStore alloc] initWithCSV:url];
    }
    return _store;
}

- (void) viewDidAppear
{
    [super viewDidAppear];

    // Individual Annotation
    //    [self.mapView addAnnotations:store.stations];
    
    // CCHMapClusterController
    [self.mapClusterController addAnnotations:self.store.stations withCompletionHandler:NULL];
}

// MKMapViewDelegate
- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if([annotation isKindOfClass:CCHMapClusterAnnotation.class]) {
        MKPinAnnotationView * view = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"MapClusters"];
        if(nil==view) {
            view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapClusters"];
        }
        if([(CCHMapClusterAnnotation *)annotation isCluster]) {
            view.pinTintColor = NSColor.greenColor;
        } else {
            view.pinTintColor = NSColor.redColor;
        }
        return view;
    }
 
    return nil;
}

@end
