### 音频通话-Swift

1. 该demo使用链接framework的方式，参考other link flags

2. 在framework search path添加framework路径

3. 添加系统库：

> 1. libc++.tbd
> 2. libxml2.tbd
> 3. libz.tbd
> 4. libiconv.tbd
> 5. AudioToolbox.framework
> 6. CoreTelephony.framework
> 7. SystemConfiguration.framework
> 8. AVFoundation.framework

4. 设置 bitcode=NO

5. 选择后台音频模式

