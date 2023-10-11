//
//  LocationPlugin.h
//  Runner
//
//  Created by PengYulong on 2023/9/11.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
NS_ASSUME_NONNULL_BEGIN

@interface LocationPlugin : NSObject <FlutterPlugin, FlutterStreamHandler>
@property FlutterMethodChannel *channel;
+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry;
- (void)sendSucessEvent:(id)result;
@end

NS_ASSUME_NONNULL_END
