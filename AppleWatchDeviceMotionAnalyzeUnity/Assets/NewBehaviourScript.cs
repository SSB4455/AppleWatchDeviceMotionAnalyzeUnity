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
	public Transform watchObj;

	public MotionParameterLineChartScript motionParameterLineChartPrefab;

    List<Hashtable> watchDataJsonList = new List<Hashtable>();
	List<MotionParameterLineChartScript> patameterChartList = new List<MotionParameterLineChartScript>();
	


	void Awake()
	{
		Screen.sleepTimeout = SleepTimeout.NeverSleep;
#if !UNITY_EDITOR
		WatchConnectivityUnityPlugin.InitWatchConnectivityUnityPlugin(name);
		WatchConnectivityUnityPlugin.SendToWatch("{\"changeData\":\"Attitude\"}");
#endif

	}

	private void Start()
	{
		patameterChartList.Add(motionParameterLineChartPrefab);
	}

	// Update is called once per frame
	void Update()
	{
		
#if UNITY_EDITOR
		if (Input.GetKeyDown(KeyCode.Space))
		{
			Hashtable json = new Hashtable();
			json.Add("ts", Time.realtimeSinceStartup);
			json.Add("gravity", new ArrayList() { 
				Convert.ToString((int)(watchObj.eulerAngles.x * 1000), 16), 
				Convert.ToString((int)((watchObj.eulerAngles.y + UnityEngine.Random.Range(0, 99)) * 1000), 16), 
				Convert.ToString((int)(watchObj.eulerAngles.y * 1000), 16), 
				Convert.ToString((int)(watchObj.eulerAngles.z * 1000), 16) });
			OnPluginCallBack(json.toJson());
		}
		//transform.parent.localRotation = Quaternion.Euler(offset_x.value, offset_y.value, offset_z.value);
#endif
	}

	public void AddPatameterLineChart()
	{
		MotionParameterLineChartScript parameterLineChart = Instantiate<MotionParameterLineChartScript>(
			motionParameterLineChartPrefab, Vector3.zero, Quaternion.identity, motionParameterLineChartPrefab.transform.parent);
		parameterLineChart.transform.SetSiblingIndex(parameterLineChart.transform.GetSiblingIndex() - 1);
		patameterChartList.Add(parameterLineChart);
		foreach (var json in watchDataJsonList)
		{
			parameterLineChart.AddDataJson(json);
		}
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

		watchDataJsonList.Add(msgJson);
		for (int i = 0; i < patameterChartList.Count; i++)
		{
			patameterChartList[i].AddDataJson(msgJson);
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
