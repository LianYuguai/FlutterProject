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

NS_ASSUME_NONNULL_BEGIN

@interface GeocodeRequest : NSObject

// Search address * Must Pass parameter
@property (nonatomic, copy) NSString *addressString;
// City name available after iOS 11.0 * Optional value
@property (nonatomic, copy) NSString *city;
// State available after ios 11.0 * Optional Values
@property (nonatomic, copy) NSString *country;

@end

NS_ASSUME_NONNULL_END
