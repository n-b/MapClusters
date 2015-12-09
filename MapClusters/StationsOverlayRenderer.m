#import "StationsOverlayRenderer.h"
#import "StationsStore.h"
#import "Station.h"

@implementation StationsOverlayRenderer

- (void)drawMapRect:(MKMapRect)mapRect
          zoomScale:(MKZoomScale)zoomScale
          inContext:(CGContextRef)context
{
    CGFloat stationRadius = MKRoadWidthAtZoomScale(zoomScale)*1.5;
    
    // We're going to need a slightly larger rect to draw stations that are just near the border
    CGRect rect = CGRectInset([self rectForMapRect:mapRect], -stationRadius, -stationRadius);
    mapRect = [self mapRectForRect:rect];
    
    StationsStore * store = self.overlay;
    for (Station * station in store.stations) {
        MKMapPoint mapPoint = MKMapPointForCoordinate(station.coordinate);
        if(!MKMapRectContainsPoint(mapRect, mapPoint)) {
            continue;
        }
        CGPoint point = [self pointForMapPoint:mapPoint];
        
        CGContextSetFillColorWithColor(context, NSColor.redColor.CGColor);
        
        CGRect stationRect = CGRectMake(point.x-stationRadius, point.y-stationRadius, stationRadius * 2, stationRadius * 2);
        CGContextFillEllipseInRect(context, CGRectIntegral(stationRect));
    }
}

@end