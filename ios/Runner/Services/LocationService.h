//
//  LocationService.h
//  Runner
//
//  Created by PengYulong on 2023/9/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocationService : NSObject
+ (instancetype) shareInstance;
- (void)initLocation;
- (void)requestLocation:(void (^)(NSDictionary *)) callBackBlock;
@end

NS_ASSUME_NONNULL_END
