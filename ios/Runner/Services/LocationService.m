//
//  LocationService.m
//  Runner
//
//  Created by PengYulong on 2023/9/11.
//

#import "LocationService.h"
#import <HMSLocation/HMSLocation.h>
#import "LocationPlugin.h"

@interface LocationService ()<HMSLocationManagerDelegate>
@end


@implementation LocationService
static id _instance = nil;
+ (instancetype) shareInstance {
    return [[self alloc] init];
}

+ (instancetype) allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}
- (void)initLocation{
    [HMSLocationManager sharedInstance].delegate = self;
    [[HMSLocationManager sharedInstance] setDesiredAccuracy:kCLLocationAccuracyBest];
    [[HMSLocationManager sharedInstance] setDistanceFilter:kCLDistanceFilterNone];

}
- (void)requestLocation:(void (^)(NSDictionary *)) callBackBlock{
//   __weak __typeof(self) weakSelf = self;
   [[HMSLocationManager sharedInstance] requestLocationWithCompletionBlock:^(HMSLoc * _Nullable hmsLocation, NSError * _Nullable error) {
//       __typeof(weakSelf) strongSelf = weakSelf;
       if (error == nil) {
           NSLog(@"lat: %lf", hmsLocation.location.coordinate.latitude);
           NSLog(@"lng: %lf", hmsLocation.location.coordinate.longitude);
           NSLog(@"country: %@", hmsLocation.country);
           NSLog(@"thoroughfare: %@", hmsLocation.thoroughfare);
           NSDictionary *dic = @{
               @"lat": @(hmsLocation.location.coordinate.latitude),
               @"lng": @(hmsLocation.location.coordinate.longitude),
               @"country": hmsLocation.country,
               @"thoroughfare": hmsLocation.thoroughfare
           };
           callBackBlock(dic);
           ReGeocodeRequest *request = [[ReGeocodeRequest alloc] init];
           request.latitude = hmsLocation.location.coordinate.latitude;
           request.longitude = hmsLocation.location.coordinate.longitude;
           [[HMSLocationManager sharedInstance] HMSReGeocodeSearch:request];
       } else {
           NSLog(@"location error: %@", error);
       }
   }];

}
- (void)onGeocodeSearchDone:(NSArray<HMSLoc *> *)requestArray{
    NSLog(@"onGeocodeSearchDone: %@", requestArray);
}
- (void)onReGeocodeSearchDone:(NSArray<HMSLoc *> *)requestArray{
    NSLog(@"onGeocodeSearchDone: %@", requestArray);
}
- (void)HMSLocationManager:(HMSLocationManager *)manager didUpdateLocation:(HMSLoc *)location{
    
}
- (void)HMSLocationManager:(HMSLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    
}
@end
