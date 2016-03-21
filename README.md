# IosPcmPlayer
在IOS上实现PCM Raw 流数据的播放，Repo使用了@Michael Tyson 的 https://github.com/michaeltyson/TPCircularBuffer， Thanks For Michael Tyson.

接口使用
---------
* 初始化
```
controller = [[AudioController alloc] init];
```
* 接口
```
//停止播放
-(void)stop;
//开始播放
-(void)start;
//把数据写入TPCiircularController
-(UInt32)writeData:(void*)buf :(UInt32)size;
//清空数据缓存
-(void)releasePlayer;
```
