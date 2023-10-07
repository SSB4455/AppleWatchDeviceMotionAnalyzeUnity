# AppleWatchDeviceMotionAnalyzeUnity

## 连接Unity和Apple Watch通信

## 说明

- 示例中的iOSBuild_AppleWatchDeviceMotionAnalyzeUnity就是一个添加了Watch应用的iOS工程
- 在Unity中Build选择iOSBuild_AppleWatchDeviceMotionAnalyzeUnity文件夹并Append来保证打出的包带有手表内容
- 手表设置要使用healthkit或其它保证黑屏能运行的方式才可以在手表黑屏的情况下发送数据
- 只有开发者账号打包后手表才能够在黑屏时继续发送姿态信息 如果是个人账号则可能在手表黑屏时停止发送消息

### 测试手表数据

``
["userAcc": ["1", "f", "-1"], "ts": 510060.1911390417, "attitude_rpy": ["-2d", "-5c", "ff"], "rotaRate": ["3c", "-e", "2"], "attitude_q": ["-2b", "-1c", "80", "3de"], "gravity": ["-2d", "5c", "-3e2"]]
``
