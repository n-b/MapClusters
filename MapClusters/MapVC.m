#import "MapVC.h"
@import MapKit;
#import "StationsStore.h"
#import "Station.h"

// Clusterers
#import "CCHMapClusterController.h"

@interface MapVC()
@property IBOutlet MKMapView * mapView;
@property (strong, nonatomic) CCHMapClusterController *mapClusterController;
@end

@implementation MapVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // CCHMapClusterController
    self.mapClusterController = [[CCHMapClusterController alloc] initWithMapView:self.mapView];

    NSURL * url = [[NSBundle bundleForClass:self.class] URLForResource:@"stations" withExtension:@"csv"];
    self.representedObject = [[StationsStore alloc] initWithCSV:url];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
    StationsStore * store = representedObject;
    
    // Individual Annotation
//    [self.mapView addAnnotations:store.stations];
    
    // CCHMapClusterController
    [self.mapClusterController addAnnotations:store.stations withCompletionHandler:NULL];
}

@end
