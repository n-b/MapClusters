#import "MapVC.h"
@import MapKit;
#import "StationsStore.h"
#import "Station.h"

@interface MapVC()
@property IBOutlet MKMapView * mapView;
@end

@implementation MapVC

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL * url = [[NSBundle bundleForClass:self.class] URLForResource:@"stations" withExtension:@"csv"];
    self.representedObject = [[StationsStore alloc] initWithCSV:url];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
    StationsStore * store = representedObject;
    
    // Individual Annotation
    [self.mapView addAnnotations:store.stations];
}

@end
