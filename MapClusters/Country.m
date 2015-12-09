#import "Country.h"
#import "GeoJSONSerialization.h"

@interface Country ()
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) NSArray<MKPolygon*>* polygons;
@end

@implementation Country

- (instancetype)init
{
    self = [super init];
    if (self) {
        _coordinate = kCLLocationCoordinate2DInvalid;
    }
    return self;
}

- (NSString *)title
{
    return self.name;
}

- (NSString *)subtitle
{
    return [NSString stringWithFormat:@"%lu stations",(unsigned long)self.stations.count];
}

- (CLLocationCoordinate2D)coordinate
{
    if(!CLLocationCoordinate2DIsValid(_coordinate)) {
        CLLocationDegrees maxLatitude = [[self.stations valueForKeyPath:@"@max.latitude"] doubleValue];
        CLLocationDegrees minLatitude = [[self.stations valueForKeyPath:@"@min.latitude"] doubleValue];
        CLLocationDegrees maxLongitude = [[self.stations valueForKeyPath:@"@max.longitude"] doubleValue];
        CLLocationDegrees minLongitude = [[self.stations valueForKeyPath:@"@min.longitude"] doubleValue];
        _coordinate = CLLocationCoordinate2DMake((minLatitude+maxLatitude)/2.0, (minLongitude+maxLongitude)/2.0);
    }
    return _coordinate;
}

- (NSArray<MKPolygon *> *)polygons
{
    if(!_polygons) {
        NSURL *URL = [[NSBundle mainBundle] URLForResource:self.name withExtension:@"json"];
        NSData *data = [NSData dataWithContentsOfURL:URL];
        NSArray *geoJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSParameterAssert(geoJSON.count==1);
        NSError * error;
        NSArray<MKPolygon*>* polygons = (id)[GeoJSONSerialization shapeFromGeoJSONFeature:geoJSON.firstObject error:&error];
        if(![polygons isKindOfClass:NSArray.class]) {
            polygons = @[polygons];
        }
        for (MKPolygon * polygon in polygons) {
            NSParameterAssert([polygon isKindOfClass:MKPolygon.class]);
        }
        self.polygons = polygons;
    }
    return _polygons;
}

@end