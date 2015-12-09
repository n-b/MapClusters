#import "StationsStore.h"
#import "Station.h"
#import "Country.h"
#import "StationsImporter.h"

@interface StationsStore () <StationsImporterDelegate>
@property NSArray<Station*>* stations;
@property NSArray<Country*>* countries;
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

@end
