//
//  MobClickJniHelper.h
//  MobClickCpp
//
//  Created by zhangziqi on 14-2-24.
//  Copyright (c) 2014年 Umeng Inc. All rights reserved.
//

#ifndef __MobClickCpp__MobClickJniHelper__
#define __MobClickCpp__MobClickJniHelper__
#include <jni.h>
namespace umeng {
    class MobClickJniHelper {
        
    public:
        static void setJavaVM(JavaVM *javaVM);
    };
}


#endif /* defined(__MobClickCpp__MobClickJniHelper__) */
