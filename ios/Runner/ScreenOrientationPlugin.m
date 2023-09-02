//
//  ScreenOrientationPlugin.m
//  Runner
//
//  Created by PengYulong on 2023/8/23.
//

#import "ScreenOrientationPlugin.h"
#import <CoreMotion/CoreMotion.h>
NSString * const EVENET_CHANNEL = @"com.oseasy.emp_mobile/event_channel";

typedef NS_ENUM(NSInteger,TgDirection) {
    TgDirectionUnkown,
    TgDirectionPortrait,
    TgDirectionDown,
    TgDirectionRight,
    TgDirectionLeft,
};

@interface ScreenOrientationPlugin ()<FlutterStreamHandler> {
    CMMotionManager *_motionManager;
    TgDirection _currentDirection;
    FlutterEventSink _eventSink;
}
@end
static const float sensitive = 0.77;
@implementation ScreenOrientationPlugin
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

- (void)registerWithRegistry:(NSObject<FlutterBinaryMessenger>*)binaryMessenger{
    /**
     UIDevice *device = [UIDevice currentDevice]; //Get the device object
     [device beginGeneratingDeviceOrientationNotifications]; //Tell it to start monitoring the accelerometer for orientation
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification  object:device];
     */
    FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:EVENET_CHANNEL binaryMessenger:binaryMessenger];

    [eventChannel setStreamHandler:self];//类似代理
    [self start];
}
- (void)orientationChanged:(NSNotification *)note  {
    UIDeviceOrientation o = [[UIDevice currentDevice] orientation];
    NSLog(@"orientationChanged: %ld", o);
}
- (void)stop {[_motionManager stopDeviceMotionUpdates];
}//陀螺仪 每隔一个间隔做轮询
- (void)start{
    if (_motionManager == nil) {
        _motionManager = [[CMMotionManager alloc] init];
    }
    _motionManager.deviceMotionUpdateInterval = 1/40.f;
    _motionManager.deviceMotionUpdateInterval = 1.0;
    if (_motionManager.deviceMotionAvailable) {
        [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]withHandler: ^(CMDeviceMotion *motion, NSError *error){
            [self performSelectorOnMainThread:@selector(deviceMotion:) withObject:motion waitUntilDone:YES];
        }];
    }
}
- (void)deviceMotion:(CMDeviceMotion *)motion{
    double x = motion.gravity.x;
    double y = motion.gravity.y;
    if (y < 0 ) {
        if (fabs(y) > sensitive && _currentDirection != TgDirectionPortrait) {
            _currentDirection = TgDirectionPortrait;
            [self sendEventMessage];
        }
    }else {
        if (y > sensitive && _currentDirection != TgDirectionDown) {
            _currentDirection = TgDirectionDown;
            [self sendEventMessage];;
        }
    }
    if (x < 0 ) {
        if (fabs(x) > sensitive && _currentDirection != TgDirectionLeft) {
            _currentDirection = TgDirectionLeft;
            [self sendEventMessage];;
        }
    }else {
        if (x > sensitive && _currentDirection != TgDirectionRight) {
            _currentDirection = TgDirectionRight;
            [self sendEventMessage];;
        }
    }
}
-(void)dealloc{
    [self stop];
}
- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    _eventSink = nil;
    return nil;
}

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)events {
    _eventSink = events;
    return nil;
}

- (void)sendEventMessage{
    NSLog(@"deviceMotion: %ld", _currentDirection);
    NSInteger angle = 0;
    switch (_currentDirection) {
        case 1:
            angle=0;
            break;
        case 4:
            angle=-90;
            break;
        case 3:
            angle=90;
            break;
        case 2:
            angle=180;
            break;
            
        default:
            break;
    }
    if(_eventSink != nil){
        _eventSink(@(angle));
    }
}

@end
