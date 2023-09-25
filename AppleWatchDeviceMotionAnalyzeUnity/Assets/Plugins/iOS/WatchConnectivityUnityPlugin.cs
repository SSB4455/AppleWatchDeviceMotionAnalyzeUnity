using System.Runtime.InteropServices;

public class WatchConnectivityUnityPlugin
{
    [DllImport("__Internal")]
    public static extern void InitWatchConnectivityUnityPlugin(string callbackObjectName);

    [DllImport("__Internal")]
    public static extern void SetCallbackObjectName(string newCallbackObjectName);

    [DllImport("__Internal")]
    public static extern void SendToWatch(string msg);

}
//https://www.dazhuanlan.com/yusisi_tomorrow/topics/1331700
//https://philm.gitbook.io/philm-ios-wiki/mei-zhou-yue-du/unity-yu-ios-ping-tai-jiao-hu-he-yuan-sheng-cha-jian-kai-fa
//https://aabao.github.io/Unity_iOS_NativPlugin/
