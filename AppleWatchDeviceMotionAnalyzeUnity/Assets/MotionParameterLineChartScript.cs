using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using XCharts.Runtime;

[RequireComponent(typeof(LineChart))]
public class MotionParameterLineChartScript : MonoBehaviour
{
	LineChart lineChart;
	public Dropdown parameterDropdown;
	List<string> lastShowParameterList = new List<string> { "gravity", "userAcc", "rotaRate", "attitude_rpy", "attitude_q" };
	string lastShowParameter;
    List<Hashtable> watchDataJsonList = new List<Hashtable>();
	


	private void Start()
	{
		lineChart = GetComponent<LineChart>();
		lineChart.ClearSerieData();

		parameterDropdown.ClearOptions();
		parameterDropdown.AddOptions(lastShowParameterList);
		parameterDropdown.onValueChanged.AddListener((value) =>
		{
			lineChart.ClearSerieData();
			lastShowParameter = parameterDropdown.options[value].text;
			foreach (var json in watchDataJsonList)
			{
				AddDataJson(json, true);
			}
		});
		parameterDropdown.value = 0;
		parameterDropdown.onValueChanged.Invoke(parameterDropdown.value);
	}

	public void AddDataJson(Hashtable dataJson, bool refresh = false)
	{
		if (!refresh)
		{
			watchDataJsonList.Add(dataJson);
		}
		//Debug.Log("dataJson " + dataJson.toJson());
		if (lastShowParameter != null && dataJson.ContainsKey(lastShowParameter))
		{
			float ts = 0;
			if (dataJson.ContainsKey("ts"))
			{
				ts = (float)(double)dataJson["ts"];
			}
			ArrayList parameterValues = dataJson[lastShowParameter] as ArrayList;
			for (int i = 0; parameterValues != null && i < parameterValues.Count; i++)
			{
				string paraStr = parameterValues[i].ToString();
				float valuei = (paraStr.StartsWith('-') ? -1 : 1) * Convert.ToInt32(paraStr.Replace("-", ""), 16) / 1000f;
				if (lineChart.series.Count < i + 1)
				{
					lineChart.series.Add(new Serie());
				}
				lineChart.series[i].AddXYData(ts, valuei);
			}
		}
	}

}
