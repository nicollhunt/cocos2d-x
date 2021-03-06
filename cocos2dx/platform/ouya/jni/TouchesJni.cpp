/****************************************************************************
Copyright (c) 2010 cocos2d-x.org

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
#include "cocoa/CCSet.h"
#include "CCDirector.h"
#include "gamepad_dispatcher/CCGamepadDispatcher.h"
#include "keypad_dispatcher/CCKeypadDispatcher.h"
#include "touch_dispatcher/CCTouch.h"
#include "../CCEGLView.h"
#include "touch_dispatcher/CCTouchDispatcher.h"

#include <android/log.h>
#include <jni.h>

using namespace cocos2d;

extern "C" {
    void Java_org_cocos2dx_lib_Cocos2dxRenderer_nativeTouchesBegin(JNIEnv * env, jobject thiz, jint id, jfloat x, jfloat y) {
    	long int l_id = id;
        cocos2d::CCDirector::sharedDirector()->getOpenGLView()->handleTouchesBegin(1, &l_id, &x, &y);
    }

    void Java_org_cocos2dx_lib_Cocos2dxRenderer_nativeTouchesEnd(JNIEnv * env, jobject thiz, jint id, jfloat x, jfloat y) {
    	long int l_id = id;
        cocos2d::CCDirector::sharedDirector()->getOpenGLView()->handleTouchesEnd(1, &l_id, &x, &y);
    }

    void Java_org_cocos2dx_lib_Cocos2dxRenderer_nativeTouchesMove(JNIEnv * env, jobject thiz, jintArray ids, jfloatArray xs, jfloatArray ys) {
        int size = env->GetArrayLength(ids);
        jint id[size];
        jfloat x[size];
        jfloat y[size];

        env->GetIntArrayRegion(ids, 0, size, id);
        env->GetFloatArrayRegion(xs, 0, size, x);
        env->GetFloatArrayRegion(ys, 0, size, y);

        long int l_id[size];
        for (int i = 0 ; i < size ; i++)
        	l_id[i] = id[i];

        cocos2d::CCDirector::sharedDirector()->getOpenGLView()->handleTouchesMove(size, l_id, x, y);
    }

    void Java_org_cocos2dx_lib_Cocos2dxRenderer_nativeTouchesCancel(JNIEnv * env, jobject thiz, jintArray ids, jfloatArray xs, jfloatArray ys) {
        int size = env->GetArrayLength(ids);
        jint id[size];
        jfloat x[size];
        jfloat y[size];

        env->GetIntArrayRegion(ids, 0, size, id);
        env->GetFloatArrayRegion(xs, 0, size, x);
        env->GetFloatArrayRegion(ys, 0, size, y);

        long int l_id[size];
		for (int i = 0 ; i < size ; i++)
			l_id[i] = id[i];

        cocos2d::CCDirector::sharedDirector()->getOpenGLView()->handleTouchesCancel(size, l_id, x, y);
    }

    jboolean Java_org_cocos2dx_lib_Cocos2dxRenderer_nativeAxisMovement(JNIEnv * env, jobject thiz, jint axisType, jfloat valX, jfloat valY, jint deviceID, jint deviceHash) {

    	CCDirector* pDirector = CCDirector::sharedDirector();
    	if (pDirector->getGamepadDispatcher()->dispatchGamepadAxisMSG((ccGamepadAxisMSGType)axisType, valX, valY, deviceID, deviceHash))
    	    return JNI_TRUE;

		return JNI_FALSE;
	}

    #define KEYCODE_BACK 0x04
    #define KEYCODE_MENU 0x52

    jboolean Java_org_cocos2dx_lib_Cocos2dxRenderer_nativeKeyDown(JNIEnv * env, jobject thiz, jint keyCode, jint deviceID, jint deviceHash) {
//    	CCLog("Java_org_cocos2dx_lib_Cocos2dxRenderer_nativeKeyDown keyCode=%d deviceID=%d deviceHash=%d", keyCode, deviceID, deviceHash);
    	CCDirector* pDirector = CCDirector::sharedDirector();

    	if (keyCode == KEYCODE_BACK && deviceHash == 0)
    	{
			if (pDirector->getKeypadDispatcher()->dispatchKeypadMSG(kTypeBackClicked))
				return JNI_TRUE;
    	}

        switch (keyCode) {
//            case KEYCODE_BACK:
//                  if (pDirector->getKeypadDispatcher()->dispatchKeypadMSG(kTypeBackClicked))
//                    return JNI_TRUE;
//                break;
//            case KEYCODE_MENU:
//                if (pDirector->getKeypadDispatcher()->dispatchKeypadMSG(kTypeMenuClicked))
//                    return JNI_TRUE;
//                break;
            default:
            	if (pDirector->getGamepadDispatcher()->dispatchGamepadBtnMSG(kTypeGamepadBtnDown, keyCode, deviceID, deviceHash))
            	    return JNI_TRUE;
        }
        return JNI_FALSE;
    }

    jboolean Java_org_cocos2dx_lib_Cocos2dxRenderer_nativeKeyUp(JNIEnv * env, jobject thiz, jint keyCode, jint deviceID, jint deviceHash) {
//    	CCLog("Java_org_cocos2dx_lib_Cocos2dxRenderer_nativeKeyUp %d", keyCode);
            CCDirector* pDirector = CCDirector::sharedDirector();
            switch (keyCode) {
//                case KEYCODE_BACK:
//                      if (pDirector->getKeypadDispatcher()->dispatchKeypadMSG(kTypeBackClicked))
//                        return JNI_TRUE;
//                    break;
//                case KEYCODE_MENU:
//                    if (pDirector->getKeypadDispatcher()->dispatchKeypadMSG(kTypeMenuClicked))
//                        return JNI_TRUE;
//                    break;
                default:
                	if (pDirector->getGamepadDispatcher()->dispatchGamepadBtnMSG(kTypeGamepadBtnUp, keyCode, deviceID, deviceHash))
                	    return JNI_TRUE;
            }
            return JNI_FALSE;
        }
}
