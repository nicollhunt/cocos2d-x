/****************************************************************************
 Created by Levire UG (haftungsbeschraenkt) & Co. KG , http://www.levire.com
 
 This program is free software. It comes without any warranty, to
 the extent permitted by applicable law. You can redistribute it
 and/or modify it under the terms of the Do What The Fuck You Want
 To Public License, Version 2, as published by Sam Hocevar. See
 http://www.wtfpl.net/ for more details.
 
 ****************************************************************************/

package com.levire.ouyabind;

import tv.ouya.console.api.OuyaController;
import android.util.Log;
import android.view.KeyEvent;

public class OuyaBindController
{	
	// Print debug logs?
    static boolean mDebugLog = false;
    static String mDebugTag = "OUYAController";

    protected static void debugLog(String message) {
    	if (mDebugLog)
    	{
    		Log.d(mDebugTag, message);
    	}
    }
    
	public static OuyaController getControllerByPlayer(int playerNum) {
		debugLog("getControllerByPlayer with Player: "+playerNum);
		OuyaController ouyaController = OuyaController.getControllerByPlayer(playerNum);
		debugLog("Found Controller: "+ouyaController);
		return ouyaController;
	}
	
	public static OuyaController getControllerByDeviceId(int deviceId)
	{
		OuyaController controller = OuyaController.getControllerByDeviceId(deviceId);
		debugLog("Got controller: "+controller);
		return controller;
	}
	
	public static native void onNativeKeyDown(final int pKeyCode, final int deviceId);
	public static boolean onKeyDown(final int pKeyCode, final KeyEvent pKeyEvent)
	{
		debugLog(String.format("onKeyDown %d", pKeyCode));
		boolean handled = OuyaController.onKeyDown(pKeyCode, pKeyEvent);
		OuyaBindController.onNativeKeyDown(pKeyCode, pKeyEvent.getDeviceId());
		return handled;
	}
	
	public static native void onNativeKeyUp(final int pKeyCode, final int deviceId);
	public static boolean onKeyUp(final int pKeyCode, final KeyEvent pKeyEvent)
	{
		debugLog(String.format("onKeyUp %d", pKeyCode));
		boolean handled = OuyaController.onKeyUp(pKeyCode, pKeyEvent);
		OuyaBindController.onNativeKeyUp(pKeyCode, pKeyEvent.getDeviceId());
		return handled;
	}
	
	public static native void onNativeLeftStickMotionEvent(final int deviceId, final float axisXValue, final float axisYValue);
	public static native void onNativeRightStickMotionEvent(final int deviceId, final float axisXValue, final float axisYValue);
	
	public static boolean onGenericMotionEvent(android.view.MotionEvent event)
	{
		boolean handled = OuyaController.onGenericMotionEvent(event);
		OuyaController controller = OuyaController.getControllerByDeviceId(event.getDeviceId());
		debugLog("onGenericMotionEvent "+ event.getDeviceId() + " " + controller);

		int player = OuyaController.getPlayerNumByDeviceId(event.getDeviceId());    
		debugLog(" - player "+ player);
	
		float LS_X = event.getAxisValue(OuyaController.AXIS_LS_X);
	    float LS_Y = event.getAxisValue(OuyaController.AXIS_LS_Y);
	    float RS_X = event.getAxisValue(OuyaController.AXIS_RS_X);
	    float RS_Y = event.getAxisValue(OuyaController.AXIS_RS_Y);
	    float L2 = event.getAxisValue(OuyaController.AXIS_L2);
	    float R2 = event.getAxisValue(OuyaController.AXIS_R2);
	    
	    OuyaBindController.onNativeLeftStickMotionEvent(event.getDeviceId(), LS_X, LS_Y);
	    
//		if (controller != null)
//		{
//			OuyaBindController.onNativeLeftStickMotionEvent(event.getDeviceId(), controller.getAxisValue(OuyaController.AXIS_LS_X), controller.getAxisValue(OuyaController.AXIS_LS_Y));
//			OuyaBindController.onNativeRightStickMotionEvent(event.getDeviceId(), controller.getAxisValue(OuyaController.AXIS_RS_X), controller.getAxisValue(OuyaController.AXIS_RS_Y));
//		}
		return handled;
	}
}
