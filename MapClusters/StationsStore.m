#import "StationsStore.h"
#import "Station.h"
#import "Country.h"
#import "StationsImporter.h"

@interface StationsStore () <StationsImporterDelegate>
@property NSArray<Station*>* stations;
@property NSArray<Country*>* countries;

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) MKMapRect boundingMapRect;
@end

@implementation StationsStore
{
    NSMutableArray<Station*>* _importStations;
}

- (instancetype)initWithCSV:(NSURL*)url
{
    self = [super init];
    _coordinate = kCLLocationCoordinate2DInvalid;
    _importStations = [NSMutableArray new];
    StationsImporter * importer = [[StationsImporter alloc] initWithCSV:url];
    importer.delegate = self;
    [importer import];
    return self;
}

- (void) importer:(StationsImporter*)importer_ didFindStation:(Station*)station_
{
    [_importStations addObject:station_];
}

- (void) importerDidFinish:(StationsImporter*)importer_
{
    self.stations = _importStations.copy;
    _importStations = nil;
    
    NSMutableDictionary<NSString*,NSMutableArray<Station*>*>* countriesStations = [NSMutableDictionary new];
    for (Station* station in self.stations) {
        NSString* countryName = station.country;
        NSMutableArray * countryStations = countriesStations[countryName];
        if(countryStations==nil) {
            countryStations = [NSMutableArray new];
            countriesStations[countryName] = countryStations;
        }
        [countryStations addObject:station];
    }
    
    NSMutableArray<Country*>* countries = [NSMutableArray new];
    for (NSString* countryName in countriesStations) {
        NSArray<Station*>* stations = countriesStations[countryName];
        Country * country = [Country new];
        country.stations = stations;
        country.name = countryName;
        [countries addObject:country];
    }
    self.countries = countries.copy;
}


// MKOverlay support
- (CLLocationCoordinate2D)coordinate
{
    [self computeOverlayCoordinate];
    return _coordinate;
}

- (MKMapRect)boundingMapRect
{
    [self computeOverlayCoordinate];
    return _boundingMapRect;
}

- (void) computeOverlayCoordinate
{
    if(!CLLocationCoordinate2DIsValid(_coordinate)) {
        CLLocationDegrees minLatitude = [[self.stations valueForKeyPath:@"@min.latitude"] doubleValue];
        CLLocationDegrees minLongitude = [[self.stations valueForKeyPath:@"@min.longitude"] doubleValue];
        CLLocationDegrees maxLatitude = [[self.stations valueForKeyPath:@"@max.latitude"] doubleValue];
        CLLocationDegrees maxLongitude = [[self.stations valueForKeyPath:@"@max.longitude"] doubleValue];
        _coordinate = CLLocationCoordinate2DMake((minLatitude+maxLatitude)/2.0, (minLongitude+maxLongitude)/2.0);
        
//        MKCoordinateRegion region;
//        region.center.latitude = (minLatitude+maxLatitude)/2.0;
//        region.center.longitude = (minLongitude+maxLongitude)/2.0;
//        region.span.latitudeDelta = maxLatitude - minLatitude;
//        region.span.longitudeDelta = maxLongitude - minLongitude; // incorrect at -/+180

        MKMapPoint a = MKMapPointForCoordinate(CLLocationCoordinate2DMake(minLatitude, minLongitude));
        MKMapPoint b = MKMapPointForCoordinate(CLLocationCoordinate2DMake(maxLatitude, maxLongitude));
        _boundingMapRect = MKMapRectMake(MIN(a.x,b.x), MIN(a.y,b.y), ABS(a.x-b.x), ABS(a.y-b.y));
    }
}

@end
