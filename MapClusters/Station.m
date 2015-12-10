#import "Station.h"

@implementation Station
- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake(self.latitude, self.longitude);
}
- (NSString *)title
{
    return self.name;
}
- (NSString *)subtitle
{
    return self.country;
}
@end
