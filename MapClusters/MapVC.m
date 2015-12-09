#import "MapVC.h"
@import MapKit;
#import "StationsStore.h"
#import "Station.h"
#import "GeoJSONSerialization.h"

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
//    [self.mapClusterController addAnnotations:self.store.stations withCompletionHandler:NULL];
    
    for (NSString* country in self.store.countries) {
        NSArray * stations = self.store.countries[country];
        NSURL *URL = [[NSBundle mainBundle] URLForResource:country withExtension:@"json"];
        NSData *data = [NSData dataWithContentsOfURL:URL];
        NSArray *geoJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSParameterAssert(geoJSON.count==1);
        NSError * error;
        NSArray<MKShape*>* shapes = (id)[GeoJSONSerialization shapeFromGeoJSONFeature:geoJSON.firstObject error:&error];
        if(![shapes isKindOfClass:NSArray.class]) {
            shapes = @[shapes];
        }
        for (MKShape * shape in shapes) {
            NSParameterAssert([shape conformsToProtocol:@protocol(MKOverlay)]);
            [self.mapView addOverlay:(id <MKOverlay>)shape];
        }
        MKPointAnnotation * center = [MKPointAnnotation new];
        center.title = country;
        center.subtitle = [NSString stringWithFormat:@"%lu stations",(unsigned long)stations.count];
        center.coordinate = shapes.firstObject.coordinate;
        [self.mapView addAnnotation:center];
    }
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

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay
{
    if([overlay isKindOfClass:MKPolygon.class]) {
        MKPolygonRenderer * renderer = [[MKPolygonRenderer alloc] initWithOverlay:overlay];
        renderer.fillColor = [NSColor.redColor colorWithAlphaComponent:.1];
        renderer.strokeColor = [NSColor.redColor colorWithAlphaComponent:.5];
        return renderer;
    } else {
        return nil;
    }
}

@end
