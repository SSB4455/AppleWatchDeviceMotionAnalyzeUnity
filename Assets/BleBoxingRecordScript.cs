using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using UnityEngine;
using UnityEngine.UI;
using XCharts;

public class BleBoxingRecordScript : MonoBehaviour
{
	Vector3 gyroAcceleration, gyroAngleAcceleration;
	Image bgImage;
	public Text outText;
	StreamReader adbOutputStream;
	public Dropdown handDropdown, recordDropdown;
	public LineChart accChart, angleAccChart;
	Serie[] accChartSeries, angleAccChartSeries;
	float startRecordTime;
	StringBuilder recordingSb = new StringBuilder();
	string[] recordFiles;



	private void Start()
	{
		handDropdown.onValueChanged.AddListener((value) =>
		{
			RefreshRecordList();
		});
		recordDropdown.onValueChanged.AddListener((value) =>
		{
			if (value == 0)
			{
				return;
			}
			ShowRecord(recordFiles[recordFiles.Length - value]);
		});
		RefreshRecordList();
		accChartSeries = new Serie[] { accChart.series.GetSerie(0), accChart.series.GetSerie(1), accChart.series.GetSerie(2) };
		angleAccChartSeries = new Serie[] { angleAccChart.series.GetSerie(0), angleAccChart.series.GetSerie(1), angleAccChart.series.GetSerie(2) };
		bgImage = transform.GetComponent<Image>();

		WatchConnectivityUnityPlugin.InitWatchConnectivityUnityPlugin(name);

		//AddRecordLine("08-12 11:24:52.394 12231 12276 I System.out: AccelerationRecordSubs: 4.349	(0.56878567, -0.1569064, 9.767424)	(0.07459708, 0.0047246725, 0.018697025)");
	}

	string outputline = "adbOutputStream.ReadLine()";
	// Update is called once per frame
	void Update()
	{
		if (adbOutputStream != null)
		{
			int loopCount = 0;
			do {
				outputline = adbOutputStream.ReadLine();
				//Debug.Log(outputline);
				outText.text = outputline;
				AddRecordLine(outputline);
			} while(!string.IsNullOrWhiteSpace(outputline) && ++loopCount < 9);
		}
	}

	void RefreshRecordList(bool showLast = false)
	{
		string fileName = (handDropdown.value == 1 ? "LeftHand_" : "RightHand_");
		recordFiles = Directory.GetFiles(Directory.GetCurrentDirectory(), "*" + fileName + "*.txt");
		string[] showFiles = new string[recordFiles.Length];
		for (int i = 0; i < recordFiles?.Length; i++)
		{
			showFiles[i] = recordFiles[i].Replace(Directory.GetCurrentDirectory(), "").Replace(".txt", "").
				Replace(Path.DirectorySeparatorChar.ToString(), "");
		}
		recordDropdown.ClearOptions();
		recordDropdown.value = 0;
		List<string> optionList = new List<string>(showFiles);
		optionList.Reverse();
		optionList.Insert(0, optionList.Count > 0 ? "出拳记录" : "没有记录");
		recordDropdown.AddOptions(optionList);
		if (showLast)
		{
			recordDropdown.value = 1;
		}
		Debug.Log("RefreshRecordList " + fileName + "\n" + string.Join(",\n", recordFiles));
	}

	void ShowRecord(string file) 
	{
		//Debug.Log("ShowRecord " + file);
		if (File.Exists(file))
		{
			accChart.xAxis0.minMaxType = Axis.AxisMinMaxType.Default;
			angleAccChart.xAxis0.minMaxType = Axis.AxisMinMaxType.Default;
			for (int i = 0; i < 3; i++)
			{
				accChartSeries[i].ClearData();
				accChartSeries[i].maxCache = 0;
				angleAccChartSeries[i].ClearData();
				angleAccChartSeries[i].maxCache = 0;
			}
			string[] lines = File.ReadAllLines(file);
			for (int i = 5; lines?.Length > 5 && i < lines?.Length; i++)
			{
				string[] splits = lines[i].Split('\t');
				float.TryParse(splits[0], out float time);
				for (int j = 1; splits?.Length > 2 && j < splits?.Length; j++)
				{
					string[] split2s = splits[j].Replace("(", "").Replace(")", "").Split(',');
					for (int k = 0; split2s.Length > 2 && k < 3; k++)
					{
						if (float.TryParse(split2s[k], out float v))
						{
							switch (j)
							{
								case 1:
									accChartSeries[k].AddXYData(time, v);
									break;
								case 2:
									angleAccChartSeries[k].AddXYData(time, v);
									break;
							}
						}
					}
				}
			}
		}
	}

	void AddRecordLine(string adbLine)
	{
		//Debug.Log("AddRecordLine " + adbLine);
		if (string.IsNullOrEmpty(adbLine) || !adbLine.Contains("AccelerationRecordSubs:"))
		{
			return;
		}

		/*if (adbLine.Contains("AccelerationRecordSubs:"))
		{
			Debug.Log("AccelerationRecordSubs\n" + adbLine);
		}

		DateTime adbLineTime = DateTime.Now;
		if (adbLine.Length > 18)
		{
			adbLineTime = DateTime.ParseExact(adbLine.Substring(0, 18), "MM-dd HH:mm:ss.fff", System.Globalization.CultureInfo.CurrentCulture);
			//Debug.Log("adbLineTime " + adbLineTime);
		}*/

		string[] splits = adbLine.Split('\t');
		if (splits?.Length > 0)
		{
			int lastIndex = splits[0].LastIndexOf(' ');
			string frameTimeStr = splits[0].Substring(lastIndex, splits[0].Length - lastIndex);
			float.TryParse(frameTimeStr, out float frameTime);
			//Debug.Log("frameTime = " + frameTime);
			dataTime = dataTime.AddSeconds(frameTime);

			Debug.Log("AccelerationRecordSubs\n" + adbLine);
			Debug.Log("dataTime = " + dataTime + ", startTime = " + startTime + "\n(dataTime - startTime).TotalSeconds = " + (dataTime - startTime).TotalSeconds);
		}
		for (int j = 1; splits?.Length > 2 && j < splits?.Length; j++)
		{
			string[] split2s = splits[j].Replace("(", "").Replace(")", "").Split(',');
			for (int k = 0; split2s.Length > 2 && k < 3; k++)
			{
				if (float.TryParse(split2s[k], out float v))
				{
					switch (j)
					{
						case 1:
							accChartSeries[k].AddXYData((dataTime - startTime).TotalSeconds, v);
							break;
						case 2:
							angleAccChartSeries[k].AddXYData((dataTime - startTime).TotalSeconds, v);
							break;
					}
				}
			}
		}
			
		
		for (int i = 0; i < 3; i++)
		{
			if (accChartSeries[i].dataCount > 99)
			{
				accChartSeries[i].data.RemoveAt(0);
			}
			if (angleAccChartSeries[i].dataCount > 99)
			{
				angleAccChartSeries[i].data.RemoveAt(0);
			}
		}
	}
	
	public void OnPluginCallBack(string msg)
	{
		Debug.Log(msg);
	}

	public void NextFileButton()
	{
		recordDropdown.value += 1;
		WatchConnectivityUnityPlugin.SendToWatch("{\"S\":" + Time.realtimeSinceStartup+",\"tt\":\"this msg\",\"audio\":true}");
	}

	public void LastFileButton()
	{
		recordDropdown.value -= 1;
	}

	DateTime dataTime = DateTime.Now;
	DateTime startTime = DateTime.Now;
	public void ReadAdbInfoButton()
	{
		var p = CreateCmdProcess("adb", "logcat -c");
		p.WaitForExit();
		p = CreateCmdProcess("adb", "logcat");
		startTime = dataTime = DateTime.Now;
		adbOutputStream = p.StandardOutput;
		accChart.xAxis0.minMaxType = Axis.AxisMinMaxType.MinMax;
		angleAccChart.xAxis0.minMaxType = Axis.AxisMinMaxType.MinMax;
		for (int i = 0; i < 3; i++)
		{
			accChartSeries[i].ClearData();
			accChartSeries[i].maxCache = 99;
			angleAccChartSeries[i].ClearData();
			angleAccChartSeries[i].maxCache = 99;
		}
	}

	public void CloseAdbInfoButton()
	{
		adbOutputStream = null;
		outText.text = "";
	}
	
	public static System.Diagnostics.Process CreateCmdProcess(string cmd, string args, string workdir = null)
	{
		var pStartInfo = new System.Diagnostics.ProcessStartInfo(cmd);
		pStartInfo.Arguments = args;
		pStartInfo.CreateNoWindow = true;
		pStartInfo.UseShellExecute = false;
		pStartInfo.RedirectStandardError = true;
		pStartInfo.RedirectStandardInput = true;
		pStartInfo.RedirectStandardOutput = true;
		pStartInfo.StandardErrorEncoding = System.Text.UTF8Encoding.UTF8;
		pStartInfo.StandardOutputEncoding = System.Text.UTF8Encoding.UTF8;
		if(!string.IsNullOrEmpty(workdir))
			pStartInfo.WorkingDirectory = workdir;
		return System.Diagnostics.Process.Start(pStartInfo);
	}
}
