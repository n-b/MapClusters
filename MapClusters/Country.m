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
    NSString * test = @"🇦🇺";
    test = [test stringByApplyingTransform:NSStringTransformToUnicodeName reverse:NO];
    test = [test stringByApplyingTransform:NSStringTransformToUnicodeName reverse:YES];

    NSArray * chars = @[[self.name substringToIndex:1], [self.name substringFromIndex:1]];
    NSMutableString * result = [NSMutableString new];
    for (NSString *character in chars) {
        NSString * s = [NSString stringWithFormat:@"\\N{REGIONAL INDICATOR SYMBOL LETTER %@}",character];
        s = [s stringByApplyingTransform:NSStringTransformToUnicodeName reverse:YES];
        [result appendString:s];
    }
    return result;
}

- (NSString *)subtitle
{
    return [NSString stringWithFormat:@"%lu stations",(unsigned long)self.stations.count];
}

- (CLLocationCoordinate2D)coordinate
{
    if(!CLLocationCoordinate2DIsValid(_coordinate)) {
        CLLocationDegrees avgLongitude = [[self.stations valueForKeyPath:@"@avg.longitude"] doubleValue];
        CLLocationDegrees avgLatitude = [[self.stations valueForKeyPath:@"@avg.latitude"] doubleValue];
        _coordinate = CLLocationCoordinate2DMake(avgLatitude, avgLongitude);
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