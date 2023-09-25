using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using XCharts.Runtime;

public class NewBehaviourScript : MonoBehaviour
{
	public Text logText;
	public LineChart angleAccChart;
	public Slider offset_x, offset_y, offset_z;
	Serie[] angleChartSeries;
	List<float> frameTime = new List<float>();
	public Dropdown recordDropdown;
	


	void Awake()
	{
		Screen.sleepTimeout = SleepTimeout.NeverSleep;
#if !UNITY_EDITOR
		WatchConnectivityUnityPlugin.InitWatchConnectivityUnityPlugin(name);
		WatchConnectivityUnityPlugin.SendToWatch("{\"changeData\":\"Attitude\"}");
#endif

		angleChartSeries = new Serie[] { angleAccChart.series[0], angleAccChart.series[1], angleAccChart.series[2], angleAccChart.series[3] };
		for (int i = 0; i < angleChartSeries.Length; i++)
		{
			angleChartSeries[i].ClearData();
			angleChartSeries[i].maxCache = 99;
		}

		recordDropdown.ClearOptions();
		List<string> optionList = new List<string> {"Attitude", "Gravity", "Acceleration"};
		recordDropdown.AddOptions(optionList);
		recordDropdown.onValueChanged.AddListener((value) =>
		{
#if !UNITY_EDITOR
			WatchConnectivityUnityPlugin.SendToWatch("{\"changeData\":\"" + recordDropdown.options[recordDropdown.value].text + "\"}");
#endif
			for (int i = 0; i < angleChartSeries.Length; i++)
			{
				angleChartSeries[i].ClearData();
				angleChartSeries[i].maxCache = 99;
			}
		});
		recordDropdown.value = 0;
	}

	// Update is called once per frame
	void Update()
	{
		
#if UNITY_EDITOR
		if (Input.GetKeyDown(KeyCode.Space))
		{
			OnPluginCallBack("{\"MT\":\"airShot\",\"airType\": \"\",\"shotCount\":" + (UnityEngine.Random.Range(0, 100)) + "}");
		}
		transform.parent.localRotation = Quaternion.Euler(offset_x.value, offset_y.value, offset_z.value);
#endif
	}

	public void ForwardCenter()
	{
		offset_x.value = 90;
		offset_y.value = 180;
		offset_z.value = (int)(-transform.localRotation.eulerAngles.z + 90 + 360) % 360;
		Debug.Log("offset_z.value = " + offset_z.value);
	}

	public void OnPluginCallBack(string msg)
	{
		Debug.Log(msg);
		logText.text = msg;

		Hashtable msgJson = null;
		try {
			msgJson = MiniJSON.jsonDecode(msg) as Hashtable;
		} catch {
			Debug.LogError("msgJson has error:" + msg);
			return;
		}

		float t1 = Time.realtimeSinceStartup;
		frameTime.Add(t1);
		while (frameTime.Count > 90)
		{
			frameTime.RemoveAt(0);
		}
		for (int i = frameTime.Count - 1; i >= 0; i--)
		{
			if (t1 - frameTime[i] > 0.5f)
			{
				logText.text += "\nwatch fps = " + ((frameTime.Count - i) / (t1 - frameTime[i]));
				break;
			}
		}

		if (msgJson.ContainsKey("att"))
		{
			string attitudeStr = msgJson["att"].ToString();
			Quaternion quaternion = Quaternion.Euler(0, 0, 0);
			string[] splits = attitudeStr.Split(',');
			for (int i = 0; i < splits.Length; i++)
			{
				string valueStr = splits[i];
				float valuei = (valueStr.StartsWith('-') ? -1 : 1) * Convert.ToInt32(valueStr.Replace("-", ""), 16) / 1000f;
				angleChartSeries[i].AddXYData(t1, valuei);
				quaternion[i] = valuei;
			}
			
			if (splits.Length > 3)
			{
				transform.localRotation = quaternion;
				transform.parent.localRotation = Quaternion.Euler(offset_x.value, offset_y.value, offset_z.value);
				logText.text += "\nz = " + transform.localRotation.eulerAngles.z;
			}
		}
	}
}
