#import <Foundation/Foundation.h>
#import <WatchConnectivity/WatchConnectivity.h>

@interface WatchConnectivityUnityPlugin : NSObject

@end

#if defined (__cplusplus)
extern "C"
{
#endif
    
    void InitWatchConnectivityUnityPlugin(char* callBackObjectName);
    void SetCallBackObjectName(char* callBackObjectName);
    void SendToWatch(char* msg);
    
#if defined (__cplusplus)
}
#endif
