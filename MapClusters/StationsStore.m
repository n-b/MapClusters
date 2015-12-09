#import "StationsStore.h"
#import "Station.h"
#import "StationsImporter.h"

@interface StationsStore () <StationsImporterDelegate>
@property NSArray<Station*>* stations;
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
}

@end
