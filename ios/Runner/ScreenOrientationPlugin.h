//
//  ScreenOrientationPlugin.h
//  Runner
//
//  Created by PengYulong on 2023/8/23.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScreenOrientationPlugin : NSObject
+ (instancetype)shareInstance;
- (void)registerWithRegistry:(NSObject<FlutterBinaryMessenger>*)binaryMessenger;
@end

NS_ASSUME_NONNULL_END
