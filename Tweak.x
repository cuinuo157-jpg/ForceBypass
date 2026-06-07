#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import <os/log.h>

// 声明我们要白嫖的函数指针类型
typedef void (*VoidFunc)(void);

__attribute__((constructor)) static void init_force_bypass() {
    // 延迟执行，确保目标的 dwrg.dylib 已经被加载或者有足够的时间被加载入内存
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        os_log(OS_LOG_DEFAULT, "[ForceBypass] 开始寻找并强制调用防封函数...");
        
        // 获取所有已加载的 image，遍历寻找 dwrg.dylib
        void *dwrg_handle = dlopen("/Library/MobileSubstrate/DynamicLibraries/dwrg.dylib", RTLD_NOLOAD);
        
        if (!dwrg_handle) {
            // 如果没找到，尝试直接加载它
            dwrg_handle = dlopen("/Library/MobileSubstrate/DynamicLibraries/dwrg.dylib", RTLD_NOW);
        }
        
        if (dwrg_handle) {
            os_log(OS_LOG_DEFAULT, "[ForceBypass] 成功获取 dwrg.dylib 句柄");
            
            // 提取防封函数 1
            VoidFunc initTersafe = (VoidFunc)dlsym(dwrg_handle, "initializeTersafeHook");
            if (initTersafe) {
                os_log(OS_LOG_DEFAULT, "[ForceBypass] 找到 initializeTersafeHook，强制执行！");
                initTersafe();
            } else {
                os_log(OS_LOG_DEFAULT, "[ForceBypass] 未找到 initializeTersafeHook");
            }
            
            // 提取防封函数 2 (多种可能的命名)
            VoidFunc enableDisguise = (VoidFunc)dlsym(dwrg_handle, "enableDeviceDisguiseBypass");
            if (!enableDisguise) {
                enableDisguise = (VoidFunc)dlsym(dwrg_handle, "DeviceDisguise");
            }
            
            if (enableDisguise) {
                os_log(OS_LOG_DEFAULT, "[ForceBypass] 找到 DeviceDisguise，强制执行！");
                enableDisguise();
            } else {
                os_log(OS_LOG_DEFAULT, "[ForceBypass] 未找到 DeviceDisguise 相关函数");
            }
            
        } else {
            os_log(OS_LOG_DEFAULT, "[ForceBypass] 无法加载或找到 dwrg.dylib");
        }
    });
}
