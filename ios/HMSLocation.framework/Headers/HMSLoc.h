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

@class CLLocation;

NS_ASSUME_NONNULL_BEGIN

@interface HMSLoc : NSObject<NSSecureCoding, NSCopying>

// The CLLocation object, which contains latitude and longitude information
@property (nonatomic, strong) CLLocation *location;
// Name of landmark
@property (nonatomic, copy) NSString *name;
// Use the ISO 3166-1alpha-2 standard, the ISO country code for the country or region
@property (nonatomic, copy) NSString *ISOCountryCode;
// Name of country or territory
@property (nonatomic, copy) NSString *country;
// Postcode
@property (nonatomic, copy) NSString *postalCode;
// A state or province associated with a landmark
@property (nonatomic, copy) NSString *administrativeArea;
// A sub-administrative region (as of a county or other region)
@property (nonatomic, copy) NSString *subAdministrativeArea;
// Landmark city
@property (nonatomic, copy) NSString *locality;
// Other city-level information on landmarks
@property (nonatomic, copy) NSString *subLocality;
// The street address contains the street name
@property (nonatomic, copy) NSString *thoroughfare;

@end



NS_ASSUME_NONNULL_END
