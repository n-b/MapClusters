#import "StationsStore.h"
#import "Station.h"
#import "StationsImporter.h"

@interface StationsStore () <StationsImporterDelegate>
@property NSArray<Station*>* stations;
@property NSDictionary<NSString*,NSArray<Station*>*>* countries;
@end

@implementation StationsStore
{
    NSMutableArray<Station*>* _importStations;
}

- (instancetype)initWithCSV:(NSURL*)url
{
    self = [super init];
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
    
    NSMutableDictionary<NSString*,NSMutableArray<Station*>*>* countries = [NSMutableDictionary new];
    for (Station* station in self.stations) {
        NSMutableArray * countryStations = countries[station.country];
        if(countryStations==nil) {
            countryStations = [NSMutableArray new];
            countries[station.country] = countryStations;
        }
        [countryStations addObject:station];
    }
    self.countries = countries.copy;
}

@end
