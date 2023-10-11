//
//  LocationPlugin.m
//  Runner
//
//  Created by PengYulong on 2023/9/11.
//

#import "LocationPlugin.h"
#import "LocationService.h"
NSString * const CHANNEL = @"com.oseasy.emp_mobile/locationMethodChannel";
NSString * const EVENET_CHANNEL_LOCATION = @"com.oseasy.emp_mobile/locationEventChannel";

@interface LocationPlugin(){
    FlutterEventSink _eventSink;
}

@end

@implementation LocationPlugin
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

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry{
    [LocationPlugin registerWithRegistrar:[registry registrarForPlugin:@"LocationPlugin"]];
}
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel *methodChannel = [FlutterMethodChannel methodChannelWithName:CHANNEL binaryMessenger:[registrar messenger] codec:[FlutterStandardMethodCodec sharedInstance]];
    LocationPlugin* instance = [LocationPlugin shareInstance];
    instance.channel = methodChannel;
    FlutterViewController *controller = (FlutterViewController *)[[[UIApplication sharedApplication] keyWindow] rootViewController];
    [instance registerWithRegistry:[controller binaryMessenger]];
    // 将插件注册为来自Dart端的传入方法调用的接收者 在指定的“ FlutterMethodChannel”上。
    [registrar addMethodCallDelegate:instance channel:methodChannel];
}
- (void)registerWithRegistry:(NSObject<FlutterBinaryMessenger>*)binaryMessenger{
    /**
     UIDevice *device = [UIDevice currentDevice]; //Get the device object
     [device beginGeneratingDeviceOrientationNotifications]; //Tell it to start monitoring the accelerometer for orientation
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification  object:device];
     */
    FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:EVENET_CHANNEL_LOCATION binaryMessenger:binaryMessenger];

    [eventChannel setStreamHandler:self];//类似代理
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result{
    if ([@"initLocation" isEqualToString:call.method]) {
        [self initLocation: result];
    } else if ([@"requestLocation" isEqualToString:call.method]) {
        [self requestLocation:result];
    } else{
        result(FlutterMethodNotImplemented);
    }
}
- (void)initLocation: (FlutterResult)result{
    [[LocationService shareInstance] initLocation];
    result(@(true));
}
- (void)requestLocation: (FlutterResult)result{
    __weak __typeof(self) weakSelf = self;
    [[LocationService shareInstance] requestLocation:^(NSDictionary * dic) {
        __typeof(weakSelf) strongSelf = weakSelf;
        LocationPlugin* instance = [LocationPlugin shareInstance];
        [strongSelf sendSucessEvent:dic];
        
    }];
    result(@(true));
}
- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    _eventSink = nil;
    return nil;
}

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)events {
    _eventSink = events;
    return nil;
}
- (void)sendSucessEvent:(id)result{
    _eventSink(result);
}

@end
