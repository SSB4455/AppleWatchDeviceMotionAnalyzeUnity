using System;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEditor;

public class ProjectBuild : Editor
{

    public static string projectPath = Application.dataPath.Substring(0, Application.dataPath.LastIndexOf("/"));


    [MenuItem("Tools/Build_iOS")]
    public static void BuildForIOS()
    {
        //BuildTarget target = EditorUserBuildSettings.activeBuildTarget;

        string GameName = "IOSBuild" + "_" + DateTime.Now.ToString("yyyyMMddHHmm");
        ///路径和包名称
        string path = "E:/UnityProjects/Build/" + GameName;

        #region 接受命令行参数
        //Debug.Log("------------- 接收命令行参数 -------------");
        //List<string> commondList = new List<string>();
        //foreach (string arg in System.Environment.GetCommandLineArgs())
        //{
        //    Debug.Log("命令行传递过来参数：" + arg);
        //    commondList.Add(arg);
        //}
        //try
        //{
        //    Debug.Log("命令行传递过来参数数量：" + commondList.Count);
        //    buildVersion = commondList[commondList.Count - 3];
        //    versionCode = int.Parse(commondList[commondList.Count - 2]);
        //    isDevelopment = bool.Parse(commondList[commondList.Count - 1]);
        //}
        //catch (Exception)
        //{
        //}
        #endregion 
        Debug.Log("------------- 更新资源 -------------");
        //BuildAssetBundle();

        BuildPipeline.BuildPlayer(GetBuildScenes(), path, BuildTarget.iOS, BuildOptions.None);
        PlayerSettings.iOS.buildNumber += 1;
    }

}
