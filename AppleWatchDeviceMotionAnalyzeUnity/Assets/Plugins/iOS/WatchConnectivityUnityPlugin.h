#import <Foundation/Foundation.h>
#import <WatchConnectivity/WatchConnectivity.h>

@interface WatchConnectivityUnityPlugin : NSObject

@end

#if defined (__cplusplus)
extern "C"
{
#endif
    
    void InitWatchConnectivityUnityPlugin(char* callbackObjectName);
    void SetCallbackObjectName(char* newCallbackObjectName);
    void SendToWatch(char* msg);
    
#if defined (__cplusplus)
}
#endif
