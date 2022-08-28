#import "WatchConnectivityUnityPlugin.h"

@implementation WatchConnectivityUnityPlugin

const char* callBackObjectName;

// 用static声明一个类的静态实例；
static WatchConnectivityUnityPlugin *_sharedInstance = nil;

//使用类方法生成这个类唯一的实例
+(WatchConnectivityUnityPlugin *)sharedInstance{
    if (!_sharedInstance) {
        NSLog(@"alloc _sharedInstance");
        _sharedInstance = [[self alloc]init];
    }
    return _sharedInstance;
}


- (void)init2 {
    NSLog(@"Init2");
    
    if ([WCSession isSupported]) {
        NSLog(@"WCSession isSupported");
        WCSession *session = [WCSession defaultSession];
        session.delegate = self;
        [session activateSession];
    } else {
        NSLog(@"WCSession is not supported with this OS version.");
    }
}

- (void)setCallBackObjectName:(char*)newCallBackObjectName {
    NSLog(@"setCallBackObjectName %s", newCallBackObjectName);
    
    callBackObjectName = newCallBackObjectName;
    callBackObjectName = [[NSString stringWithUTF8String: newCallBackObjectName] UTF8String];
    
    //callBackObjectName = [nsData bytes];
    NSLog(@"callBackObjectName %s", callBackObjectName);
}

- (void)sendMessage:(char*)msg {
    NSLog(@"sendMessage %s", msg);
    
    NSError *jsonError;
    NSData *objectData = [[NSString stringWithUTF8String: msg] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *msgDict = [NSJSONSerialization JSONObjectWithData:objectData
                                          options:NSJSONReadingAllowFragments
                                            error:&jsonError];

    WCSession *session = [WCSession defaultSession];
    [session sendMessage:msgDict replyHandler:^(NSDictionary<NSString *, id> * _Nonnull replyMessage) {
        
    } errorHandler:^(NSError * _Nonnull error) {
        NSLog(@"sendMessage error %@", error.localizedDescription);
    }];
}

- (void)session: (nonnull WCSession *)session didReceiveMessage:(nonnull NSDictionary<NSString *,id> *)message replyHandler:(nonnull void (^)(NSDictionary<NSString *,id> * _Nonnull))replyHandler{
    //NSLog(@"WCSession didReceiveMessage");
    NSLog(@"callBackObjectName %s", callBackObjectName);
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:message
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (!jsonData) {
        NSLog(@"Got an error: %@", error);
        UnitySendMessage(callBackObjectName, "OnPluginCallBack", "didReceiveMessage error");
    } else {
        const char *jsonString = [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] UTF8String];
        //NSLog(@"jsonString\n%s", jsonString);
        UnitySendMessage(callBackObjectName, "OnPluginCallBack", jsonString);
    }
}

- (void)session: (nonnull WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(nullable NSError *)error{
    
    NSLog(@"WCSession activationDidCompleteWithState");
    UnitySendMessage(callBackObjectName, "OnPluginCallBack", "inti ok");
}

- (void)sessionDidDeactivate:(WCSession *)session {
    
    NSLog(@"WCSession sessionDidDeactivate");
}

- (void) sessionDidBecomeInactive:(WCSession *)session {
    
    NSLog(@"WCSession sessionDidBecomeInactive");
}

NSString* CreateNSString (const char* string)
 {
   if (string)
     return [NSString stringWithUTF8String: string];
   else
     return [NSString stringWithUTF8String: ""];
 }

@end

#if defined (__cplusplus)
extern "C"
{
#endif
    
    void InitWatchConnectivityUnityPlugin(char* callBackObjectName) {
        WatchConnectivityUnityPlugin *instance = [WatchConnectivityUnityPlugin sharedInstance];
        @synchronized(instance) {
            [instance setCallBackObjectName: callBackObjectName];
            [instance init2];
        }
    }
    
    void SetCallBackObjectName(char* callBackObjectName) {
        WatchConnectivityUnityPlugin *instance = [WatchConnectivityUnityPlugin sharedInstance];
        @synchronized(instance) {
            [instance setCallBackObjectName: callBackObjectName];
        }
    }
    
    void SendToWatch(char* msg) {
        WatchConnectivityUnityPlugin *instance = [WatchConnectivityUnityPlugin sharedInstance];
        @synchronized(instance) {
            //NSLog(@"%s", msg);
            [instance sendMessage: msg];
        }
    }
    
#if defined (__cplusplus)
}
#endif

