#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import <os/log.h>

typedef void (*VoidFunc)(void);

__attribute__((constructor)) static void init_force_bypass() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        os_log(OS_LOG_DEFAULT, "[ForceBypass] 开始寻找并强制调用防封函数...");
        
        // 尝试 RootHide 路径 (Dopamine/RootHide)
        void *dwrg_handle = dlopen("/var/jb/Library/MobileSubstrate/DynamicLibraries/dwrg.dylib", RTLD_NOLOAD);
        if (!dwrg_handle) dwrg_handle = dlopen("/var/jb/Library/MobileSubstrate/DynamicLibraries/dwrg.dylib", RTLD_NOW);
        
        // 备选兼容标准路径
        if (!dwrg_handle) {
            dwrg_handle = dlopen("/Library/MobileSubstrate/DynamicLibraries/dwrg.dylib", RTLD_NOLOAD);
        }
        if (!dwrg_handle) {
            dwrg_handle = dlopen("/Library/MobileSubstrate/DynamicLibraries/dwrg.dylib", RTLD_NOW);
        }
        
        if (dwrg_handle) {
            os_log(OS_LOG_DEFAULT, "[ForceBypass] 成功获取 dwrg.dylib 句柄");
            
            VoidFunc initTersafe = (VoidFunc)dlsym(dwrg_handle, "initializeTersafeHook");
            if (initTersafe) {
                os_log(OS_LOG_DEFAULT, "[ForceBypass] 找到 initializeTersafeHook，强制执行！");
                initTersafe();
            }
            
            VoidFunc enableDisguise = (VoidFunc)dlsym(dwrg_handle, "enableDeviceDisguiseBypass");
            if (!enableDisguise) enableDisguise = (VoidFunc)dlsym(dwrg_handle, "DeviceDisguise");
            
            if (enableDisguise) {
                os_log(OS_LOG_DEFAULT, "[ForceBypass] 找到 DeviceDisguise，强制执行！");
                enableDisguise();
            }
        } else {
            os_log(OS_LOG_DEFAULT, "[ForceBypass] 无法加载或找到 dwrg.dylib");
        }
    });
}
