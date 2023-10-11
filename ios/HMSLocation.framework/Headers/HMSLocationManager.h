/*
*       Copyright 2021. Huawei Technologies Co., Ltd. All rights reserved.

        Licensed under the Apache License, Version 2.0 (the "License");
        you may not use this file except in compliance with the License.
        You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0
 
         Unless required by applicable law or agreed to in writing, software
        distributed under the License is distributed on an "AS IS" BASIS,
        WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
        See the License for the specific language governing permissions and
        limitations under the License.
*/

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class HMSLoc;
@class GeocodeRequest;
@class ReGeocodeRequest;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, HMSAuthorizationType) {
    HMSAuthorizationTypeAuto = 0,
    HMSAuthorizationTypeAlways,
    HMSAuthorizationTypeWhenInUse,
};

typedef NS_ENUM(NSUInteger, GeocodeType) {
    GeocodeTypeForward = 0,
    GeocodeTypeReverse
};

typedef NS_ENUM(NSUInteger, HMSCoordinateType) {
    HMSCoordinateWGS84 = 0,
    HMSCoordinateGCJ02
};

typedef NS_ENUM(NSUInteger, HMSErrorType) {
    INTERNAL_ERROR      = 10000,
    PARAM_ERROR_EMPTY   = 10801,
    PARAM_ERROR_INVALID = 10802,
    PERMISSION_DENIED   = 10803,
    AGC_CHECK_FAIL      = 10808,
    NETWORK_ERROR       = 10809
};

typedef void (^HMSLocatingCompletionBlock)(HMSLoc * _Nullable location, NSError  * _Nullable error);

typedef void (^HMLocationConverterCompletionBlock) (CLLocationCoordinate2D resultCoordinate, NSError * _Nullable error);

@protocol HMSLocationManagerDelegate;

@interface HMSLocationManager : NSObject

@property (nonatomic, weak) id<HMSLocationManagerDelegate> delegate;

// Location Minimum Update Distance
@property (nonatomic, assign) CLLocationDistance distanceFilter;

// API Key
@property (nonatomic, assign) NSString *apiKey;

// Type of authorization
@property (nonatomic, assign) HMSAuthorizationType preferredAuthorizationType;

// Positioning accuracy
@property (nonatomic, assign) CLLocationAccuracy desiredAccuracy;

// Specifies whether the positioning is automatically paused by the system. The default is YES
@property (nonatomic, assign) BOOL pausesLocationUpdatesAutomatically;

// If background positioning is allowed, the default is NO
@property (nonatomic, assign) BOOL allowsBackgroundLocationUpdates;

// How often [0,180] degrees are called when the orientation changes
@property (nonatomic, assign) CLLocationDegrees headingFilter;

// Device orientation
@property (nonatomic, assign) CLDeviceOrientation headingOrientation;

// Single location timeout, default 10s, minimum 2s
@property (nonatomic, assign) NSInteger locationTimeout;

// Returns the coordinate type, default HMSCoordinateWGS84
@property (nonatomic, assign) HMSCoordinateType coordinateType;

#pragma mark -Disables init
/**
 * @brief Override the init function
 */
- (instancetype)init NS_UNAVAILABLE;

#pragma mark -Authorizations
/**
 * @brief Request location authorization while using the APP
 */
- (void)requestWhenInUseAuthorization;

/**
 * @brief Request always use location authorization
 */
- (void)requestAlwaysAuthorization;

#pragma mark -Open function

/**
 * @brief Create a singleton object
 */
+ (instancetype)sharedInstance;

/**
 * @brief Returns whether the location service is available to the user
 */
+ (BOOL)locationServicesEnabled;

/**
 * @brief Single location requested
 * @prarm completionBlock Requesting a successful callback
 */
- (BOOL)requestLocationWithCompletionBlock:(HMSLocatingCompletionBlock)completionBlock;

/**
 * @brief Initiate Location Update
 */
- (void)startUpdatingLocation;

/**
 * @brief Stop Location Update
 */
- (void)stopUpdatingLocation;

/**
 * @brief It’s starting to move towards renewal
 */
- (void)startUpdatingHeading;

/**
 * @brief Try to start an active authentication
 */
- (void)startAuthorize;

/**
 * @brief Stop updating orientation
 */

- (void)stopUpdatingHeading;

/**
 * @brief Stop proofreading
 */
- (void)dismissHeadingCalibrationDisplay;

/**
 * @brief Positive geocoding query interface
 * @param geocodeRequest Requesting entity
 */
- (void)HMSGeocodeSearch:(GeocodeRequest *)geocodeRequest;

/**
 * @brief Inverse geocoding query interface
 * @param reGeocodeRequest Requesting entity
 */
- (void)HMSReGeocodeSearch:(ReGeocodeRequest *)reGeocodeRequest;

/**
 * @brief The World Standard Geographic coordinates (WGS-84) are converted into the geographic coordinates of China National Survey Bureau (GCJ-02)
 *
 *  ####Only coordinates in the Chinese mainland range are valid and return world standard coordinates directly outside
 *
 * @param location     World Standard Geographical Coordinates (WGS-84)
 *
 *@param converterCompletionBlock The coordinate transformation returns a result set in which the resultCoordinate represents the geographical coordinates of the China National Survey Bureau (GCJ-02)
 */
+ (void)wgs84ToGcj02:(CLLocationCoordinate2D)location completionBlock:(HMLocationConverterCompletionBlock)converterCompletionBlock;

@end


#pragma mark - HMSLocationManagerDelegate

@protocol HMSLocationManagerDelegate <NSObject>
@optional

/**
 * @brief Location failure, geocoding failure callback
 * @param manager HMSLocationManager Object
 * @param error Error Message
 */
- (void)HMSLocationManager:(HMSLocationManager *)manager didFailWithError:(NSError *)error;

/**
 * @brief Position Update callback
 * @param manager HMSLocationManager Object
 * @param location Location Information
 */
- (void)HMSLocationManager:(HMSLocationManager *)manager didUpdateLocation:(HMSLoc *)location;

/**
 * @brief Location Permission Change callback
 * @param manager HMSLocationManager Object
 * @param status Permission type
 */
- (void)HMSLocationManager:(HMSLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status;

/**
 * @brief Orientation Update callback
 * @param manager HMSLocationManager Object
 * @param newHeading Toward Information
 */
- (void)HMSLocationManager:(HMSLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading;

/**
 * @brief No is not displayed by default
 * @param manager HMSLocationManager Object
 */
- (BOOL)HMSLocationManagerShouldDisplayHeadingCalibration:(HMSLocationManager *)manager;

/**
 * @brief Positive geocoding query callback function
 * @param requestArray Response result
 */
- (void)onGeocodeSearchDone:(NSArray<HMSLoc *>*)requestArray;

/**
 * @brief Inverse geocoding query callback function
 * @param requestArray Response result.
 */
- (void)onReGeocodeSearchDone:(NSArray<HMSLoc *>*)requestArray;

@end


NS_ASSUME_NONNULL_END
