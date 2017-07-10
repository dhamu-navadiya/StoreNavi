/*
    Copyright (C) 2014 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    
                This class converts coordinates from Geographic coordinate system to floorplan space.
            
*/

@import CoreLocation;
@import UIKit;

typedef struct {
	CLLocationCoordinate2D latitudeLongitude;
	CGPoint pixel;
}  GeoAnchor;

typedef struct {
	GeoAnchor fromAnchor;
	GeoAnchor toAnchor;
} GeoAnchorPair;

@interface CoordinateConverter : NSObject

- (instancetype)initWithCoordinatesTopLeft:(CLLocationCoordinate2D)topLeft bottomRight:(CLLocationCoordinate2D)bottomRight imageSize:(CGSize)imageSize;

- (instancetype)initWithAnchors:(GeoAnchorPair)anchors;

// Floorplan pixels per meter
@property (assign, nonatomic, readonly) CGFloat pixelsPerMeter;

// Returns a CGPoint for where coordinates sit on the floorplan
- (CGPoint)pointFromCoordinate:(CLLocationCoordinate2D)coordinates;

@end
