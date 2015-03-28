/****************************************************************************
Copyright (c) 2010-2011 cocos2d-x.org

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
package org.cocos2dx.lib;

import java.lang.reflect.Method;

import org.cocos2dx.lib.Cocos2dxGLSurfaceView;

import android.content.Context;
import android.opengl.GLSurfaceView;
import android.os.Handler;
import android.os.Message;
import android.util.AttributeSet;
import android.util.Log;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.inputmethod.InputMethodManager;

public class Cocos2dxGLSurfaceView extends GLSurfaceView {
	// ===========================================================
	// Constants
	// ===========================================================

	private static final String TAG = Cocos2dxGLSurfaceView.class.getSimpleName();

	private final static int HANDLER_OPEN_IME_KEYBOARD = 2;
	private final static int HANDLER_CLOSE_IME_KEYBOARD = 3;
	
	private final static boolean mDisplayGamepadDebug = false;

	// ===========================================================
	// Fields
	// ===========================================================

	// TODO Static handler -> Potential leak!
	private static Handler sHandler;

	private static Cocos2dxGLSurfaceView mCocos2dxGLSurfaceView;
	private static Cocos2dxTextInputWraper sCocos2dxTextInputWraper;

	private Cocos2dxRenderer mCocos2dxRenderer;
	private Cocos2dxEditText mCocos2dxEditText;
	
	// ===========================================================
	// Constructors
	// ===========================================================

	public Cocos2dxGLSurfaceView(final Context context) {
		super(context);

		this.setEGLContextClientVersion(2);

		this.initView();
	}

	public Cocos2dxGLSurfaceView(final Context context, final AttributeSet attrs) {
		super(context, attrs);

		this.setEGLContextClientVersion(2);

		this.initView();
	}

	protected void initView() {
		this.setFocusableInTouchMode(true);

		Cocos2dxGLSurfaceView.mCocos2dxGLSurfaceView = this;
		Cocos2dxGLSurfaceView.sCocos2dxTextInputWraper = new Cocos2dxTextInputWraper(this);

		Cocos2dxGLSurfaceView.sHandler = new Handler() {
			@Override
			public void handleMessage(final Message msg) {
				switch (msg.what) {
					case HANDLER_OPEN_IME_KEYBOARD:
						if (null != Cocos2dxGLSurfaceView.this.mCocos2dxEditText && Cocos2dxGLSurfaceView.this.mCocos2dxEditText.requestFocus()) {
							Cocos2dxGLSurfaceView.this.mCocos2dxEditText.removeTextChangedListener(Cocos2dxGLSurfaceView.sCocos2dxTextInputWraper);
							Cocos2dxGLSurfaceView.this.mCocos2dxEditText.setText("");
							final String text = (String) msg.obj;
							Cocos2dxGLSurfaceView.this.mCocos2dxEditText.append(text);
							Cocos2dxGLSurfaceView.sCocos2dxTextInputWraper.setOriginText(text);
							Cocos2dxGLSurfaceView.this.mCocos2dxEditText.addTextChangedListener(Cocos2dxGLSurfaceView.sCocos2dxTextInputWraper);
							final InputMethodManager imm = (InputMethodManager) Cocos2dxGLSurfaceView.mCocos2dxGLSurfaceView.getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
							imm.showSoftInput(Cocos2dxGLSurfaceView.this.mCocos2dxEditText, 0);
							Log.d("GLSurfaceView", "showSoftInput");
						}
						break;

					case HANDLER_CLOSE_IME_KEYBOARD:
						if (null != Cocos2dxGLSurfaceView.this.mCocos2dxEditText) {
							Cocos2dxGLSurfaceView.this.mCocos2dxEditText.removeTextChangedListener(Cocos2dxGLSurfaceView.sCocos2dxTextInputWraper);
							final InputMethodManager imm = (InputMethodManager) Cocos2dxGLSurfaceView.mCocos2dxGLSurfaceView.getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
							imm.hideSoftInputFromWindow(Cocos2dxGLSurfaceView.this.mCocos2dxEditText.getWindowToken(), 0);
							Cocos2dxGLSurfaceView.this.requestFocus();
							Log.d("GLSurfaceView", "HideSoftInput");
						}
						break;
				}
			}
		};
		
		// Hide navigation controls where possible...
		initSystemUiVisibility();
	}

	// ===========================================================
	// Getter & Setter
	// ===========================================================


       public static void queueAccelerometer(final float x, final float y, final float z, final long timestamp) {	
	   mCocos2dxGLSurfaceView.queueEvent(new Runnable() {
		@Override
		    public void run() {
			    Cocos2dxAccelerometer.onSensorChanged(x, y, z, timestamp);
		}
	    });
	}

	public void setCocos2dxRenderer(final Cocos2dxRenderer renderer) {
		this.mCocos2dxRenderer = renderer;
		this.setRenderer(this.mCocos2dxRenderer);
	}

	private String getContentText() {
		return this.mCocos2dxRenderer.getContentText();
	}

	public Cocos2dxEditText getCocos2dxEditText() {
		return this.mCocos2dxEditText;
	}

	public void setCocos2dxEditText(final Cocos2dxEditText pCocos2dxEditText) {
		this.mCocos2dxEditText = pCocos2dxEditText;
		if (null != this.mCocos2dxEditText && null != Cocos2dxGLSurfaceView.sCocos2dxTextInputWraper) {
			this.mCocos2dxEditText.setOnEditorActionListener(Cocos2dxGLSurfaceView.sCocos2dxTextInputWraper);
			this.mCocos2dxEditText.setCocos2dxGLSurfaceView(this);
			this.requestFocus();
		}
	}
	
	final int nVisibilityFlags = View.SYSTEM_UI_FLAG_LAYOUT_STABLE
	            | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
	            | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
	            | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION // hide nav bar
	            | View.SYSTEM_UI_FLAG_FULLSCREEN
	            | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY;
	
	//
	// Attempt to put app into fullscreen mode, or as close as system allows...
	//
	public void initSystemUiVisibility()
	{
		int SDK_INT = android.os.Build.VERSION.SDK_INT;
		
		Log.d("cocos2dx debug info", String.format("android.os.Build.VERSION.SDK_INT = %d", SDK_INT));
		
		if(SDK_INT >= 19)
		{			
			// Also set flags if something else changes them, e.g. volume hardware buttons, etc...
			setOnSystemUiVisibilityChangeListener(new OnSystemUiVisibilityChangeListener() {
	            @Override
	            public void onSystemUiVisibilityChange(int visibility)
	            {
	            	Log.d("cocos2dx debug info", String.format("onSystemUiVisibilityChange %d", visibility) );
	                if(visibility == 0)
	                {
	                	mCocos2dxGLSurfaceView.setSystemUiVisibility(nVisibilityFlags);
	                }
	            }
	        });
		}
		
		updateSystemUiVisibility();
	}
	
	public void updateSystemUiVisibility()
	{
		int SDK_INT = android.os.Build.VERSION.SDK_INT;
				
		if(SDK_INT >= 19)
		{	
			// Set flags immediately
			setSystemUiVisibility(nVisibilityFlags);
		}
		else if(SDK_INT >= 14)
		{
			// Request dimmed state of soft keyboard
			setSystemUiVisibility(View.SYSTEM_UI_FLAG_LOW_PROFILE);
		}		
	}

	// ===========================================================
	// Methods for/from SuperClass/Interfaces
	// ===========================================================

	@Override
	public void onResume() {
		super.onResume();
				
		this.queueEvent(new Runnable() {
			@Override
			public void run() {
				Cocos2dxGLSurfaceView.this.mCocos2dxRenderer.handleOnResume();
			}
		});
	}

	@Override
	public void onPause() {
		this.queueEvent(new Runnable() {
			@Override
			public void run() {
				Cocos2dxGLSurfaceView.this.mCocos2dxRenderer.handleOnPause();
			}
		});

		super.onPause();
	}

	@Override
	public boolean onTouchEvent(final MotionEvent pMotionEvent) {
				
		updateSystemUiVisibility();

		// these data are used in ACTION_MOVE and ACTION_CANCEL
		final int pointerNumber = pMotionEvent.getPointerCount();
		final int[] ids = new int[pointerNumber];
		final float[] xs = new float[pointerNumber];
		final float[] ys = new float[pointerNumber];

		for (int i = 0; i < pointerNumber; i++) {
			ids[i] = pMotionEvent.getPointerId(i);
			xs[i] = pMotionEvent.getX(i);
			ys[i] = pMotionEvent.getY(i);
		}

		switch (pMotionEvent.getAction() & MotionEvent.ACTION_MASK) {
			case MotionEvent.ACTION_POINTER_DOWN:
				final int indexPointerDown = pMotionEvent.getAction() >> MotionEvent.ACTION_POINTER_ID_SHIFT;
				final int idPointerDown = pMotionEvent.getPointerId(indexPointerDown);
				final float xPointerDown = pMotionEvent.getX(indexPointerDown);
				final float yPointerDown = pMotionEvent.getY(indexPointerDown);

				this.queueEvent(new Runnable() {
					@Override
					public void run() {
						Cocos2dxGLSurfaceView.this.mCocos2dxRenderer.handleActionDown(idPointerDown, xPointerDown, yPointerDown);
					}
				});
				break;

			case MotionEvent.ACTION_DOWN:
				// there are only one finger on the screen
				final int idDown = pMotionEvent.getPointerId(0);
				final float xDown = xs[0];
				final float yDown = ys[0];

				this.queueEvent(new Runnable() {
					@Override
					public void run() {
						Cocos2dxGLSurfaceView.this.mCocos2dxRenderer.handleActionDown(idDown, xDown, yDown);
					}
				});
				break;

			case MotionEvent.ACTION_MOVE:
				this.queueEvent(new Runnable() {
					@Override
					public void run() {
						Cocos2dxGLSurfaceView.this.mCocos2dxRenderer.handleActionMove(ids, xs, ys);
					}
				});
				break;

			case MotionEvent.ACTION_POINTER_UP:
				final int indexPointUp = pMotionEvent.getAction() >> MotionEvent.ACTION_POINTER_ID_SHIFT;
				final int idPointerUp = pMotionEvent.getPointerId(indexPointUp);
				final float xPointerUp = pMotionEvent.getX(indexPointUp);
				final float yPointerUp = pMotionEvent.getY(indexPointUp);

				this.queueEvent(new Runnable() {
					@Override
					public void run() {
						Cocos2dxGLSurfaceView.this.mCocos2dxRenderer.handleActionUp(idPointerUp, xPointerUp, yPointerUp);
					}
				});
				break;

			case MotionEvent.ACTION_UP:
				// there are only one finger on the screen
				final int idUp = pMotionEvent.getPointerId(0);
				final float xUp = xs[0];
				final float yUp = ys[0];

				this.queueEvent(new Runnable() {
					@Override
					public void run() {
						Cocos2dxGLSurfaceView.this.mCocos2dxRenderer.handleActionUp(idUp, xUp, yUp);
					}
				});
				break;

			case MotionEvent.ACTION_CANCEL:
				this.queueEvent(new Runnable() {
					@Override
					public void run() {
						Cocos2dxGLSurfaceView.this.mCocos2dxRenderer.handleActionCancel(ids, xs, ys);
					}
				});
				break;
		}

        /*
		if (BuildConfig.DEBUG) {
			Cocos2dxGLSurfaceView.dumpMotionEvent(pMotionEvent);
		}
		*/
		return true;
	}

	/*
	 * This function is called before Cocos2dxRenderer.nativeInit(), so the
	 * width and height is correct.
	 */
	@Override
	protected void onSizeChanged(final int pNewSurfaceWidth, final int pNewSurfaceHeight, final int pOldSurfaceWidth, final int pOldSurfaceHeight) {
		if(!this.isInEditMode()) {
			this.mCocos2dxRenderer.setScreenWidthAndHeight(pNewSurfaceWidth, pNewSurfaceHeight);
		}
	}

	public int getDeviceId(final android.view.InputEvent pEvent) {
		try
		{
			final android.view.InputDevice device = pEvent.getDevice();
			if (device == null) {
				return -1;
			}
			return device.getId();
		}
		catch (NoClassDefFoundError e)
		{
			return -1;
		}
	}
	
	public String getDeviceDescriptor(final android.view.InputEvent pEvent) {
		try
		{
			final android.view.InputDevice device = pEvent.getDevice();
			if (device == null) {
				return "Default";
			}
			String desc = null;

			// The Amazon Kindle HD doesn't support InputDevice.getDescriptor for some reason
			// so fall back to getName() in that case
			try
			{
				Method m = android.view.InputDevice.class.getMethod("getDescriptor");
				desc = device.getDescriptor();
			} 
			catch (Exception e)
			{
				desc = device.getName();
			}

			return desc;
		}
		catch (NoClassDefFoundError e)
		{
			return "Default";
		}
	}
	
	public int getDeviceHash(final android.view.InputEvent pEvent) {
	     String deviceData = getDeviceDescriptor(pEvent);
	     return deviceData.hashCode();
	}
	
	@Override
	public boolean onGenericMotionEvent(final MotionEvent pEvent)
	{
		if (mDisplayGamepadDebug)
		{
			Log.d(Cocos2dxGLSurfaceView.TAG, String.format("onGenericMotionEvent source=%d action=%d",
					pEvent.getSource(),
					pEvent.getAction()));
		}
		
		if (pEvent.getSource() == android.view.InputDevice.SOURCE_JOYSTICK) {
			if (pEvent.getAction() == MotionEvent.ACTION_MOVE) {

				final int deviceId = getDeviceId(pEvent);
				final int deviceHash = getDeviceHash(pEvent);

				final float xVal = pEvent.getAxisValue(MotionEvent.AXIS_X);
				final float yVal = pEvent.getAxisValue(MotionEvent.AXIS_Y);

				if (mDisplayGamepadDebug)
				{
					Log.d(Cocos2dxGLSurfaceView.TAG, String.format("onGenericMotionEvent %.2f,%.2f - Id = %d Hash = %d",
							xVal,
							yVal,
							deviceId,
							deviceHash
							));
				}

				this.queueEvent(new Runnable() {
					@Override
					public void run() {
						Cocos2dxGLSurfaceView.this.mCocos2dxRenderer.handleAxisMovement(0, xVal, yVal, deviceId, deviceHash);
					}
				});

				// For some obscure reason the dpad stuff (on the Red Samurai controller at least) goes through
				// here first and if we don't call the base class it never makes it to onKeyDown()
				// I HATE FUCKING ANDROID CONTROLLER BULLSHIT
				//	             return true;
			}
		}

		return super.onGenericMotionEvent(pEvent);
	}
	
	public int[] mValidGamePadKeyCodes = 
		{
			KeyEvent.KEYCODE_MENU,
			KeyEvent.KEYCODE_BACK,
			
			KeyEvent.KEYCODE_DPAD_UP,
			KeyEvent.KEYCODE_DPAD_DOWN,
			KeyEvent.KEYCODE_DPAD_LEFT,
			KeyEvent.KEYCODE_DPAD_RIGHT,
			KeyEvent.KEYCODE_BUTTON_1,
			KeyEvent.KEYCODE_BUTTON_2,
			KeyEvent.KEYCODE_BUTTON_3,
			KeyEvent.KEYCODE_BUTTON_4,
			KeyEvent.KEYCODE_BUTTON_5,
			KeyEvent.KEYCODE_BUTTON_6,
			KeyEvent.KEYCODE_BUTTON_7,
			KeyEvent.KEYCODE_BUTTON_8,
			KeyEvent.KEYCODE_BUTTON_9,
			KeyEvent.KEYCODE_BUTTON_10,
			KeyEvent.KEYCODE_BUTTON_11,
			KeyEvent.KEYCODE_BUTTON_12,
			KeyEvent.KEYCODE_BUTTON_13,
			KeyEvent.KEYCODE_BUTTON_14,
			KeyEvent.KEYCODE_BUTTON_15,
			KeyEvent.KEYCODE_BUTTON_16,
			KeyEvent.KEYCODE_BUTTON_A,
			KeyEvent.KEYCODE_BUTTON_B,
			KeyEvent.KEYCODE_BUTTON_C,
			KeyEvent.KEYCODE_BUTTON_L1,
			KeyEvent.KEYCODE_BUTTON_L2,
			KeyEvent.KEYCODE_BUTTON_R1,
			KeyEvent.KEYCODE_BUTTON_R2,
			KeyEvent.KEYCODE_BUTTON_SELECT,
			KeyEvent.KEYCODE_BUTTON_START,
			KeyEvent.KEYCODE_BUTTON_THUMBL,
			KeyEvent.KEYCODE_BUTTON_THUMBR,
			KeyEvent.KEYCODE_BUTTON_X,
			KeyEvent.KEYCODE_BUTTON_Y,
			KeyEvent.KEYCODE_BUTTON_Z
		};
	
	public boolean shouldConsumeKeyEvent(final int pKeyCode, final KeyEvent pKeyEvent)
	{
		boolean bConsume = false;
				
		for (int valid_key_code : mValidGamePadKeyCodes)
		{
			if (pKeyCode == valid_key_code)
			{
				bConsume = true;
				break;
			}		    	 
		}
		
		if (!bConsume)
		{
			// Not all Android versions support isGamepadButton and/or getSource
			Method m = null;
			try {
				m = KeyEvent.class.getMethod("isGamepadButton");
				bConsume = KeyEvent.isGamepadButton(pKeyCode);
			} catch (Exception e) {} // doesn't matter
		}
		
		if (!bConsume)
		{
			// Not all Android versions support isGamepadButton and/or getSource
			Method m = null;
			try {
				m = KeyEvent.class.getMethod("getSource");
				bConsume = (pKeyEvent.getSource() & android.view.InputDevice.SOURCE_JOYSTICK) != 0;
			} catch (Exception e) {} // doesn't matter
		}
		
		if (mDisplayGamepadDebug)
		{
			Log.d(Cocos2dxGLSurfaceView.TAG, String.format("shouldConsumeKeyEvent %s - source=%d pKeyCode=%d", 
					bConsume ? "TRUE" : "FALSE", 
							pKeyEvent.getSource(), 
							pKeyCode));		
		}

		return bConsume;
	}
	
	@Override
	public boolean onKeyDown(final int pKeyCode, final KeyEvent pKeyEvent) {
	
		// Ignore repeated keys
		if (pKeyEvent.getRepeatCount() != 0)
			return true;

 	    if (mDisplayGamepadDebug)
 	    {
 	    	Log.d(Cocos2dxGLSurfaceView.TAG, String.format("onKeyDown %d pKeyEvent.getSource()=%d",pKeyCode, pKeyEvent.getSource()));
 	    }
 	    
		if (shouldConsumeKeyEvent(pKeyCode, pKeyEvent)) 
		{
			final int pDeviceId = getDeviceId(pKeyEvent);
			final int pDeviceHash = getDeviceHash(pKeyEvent);
			
     	    if (mDisplayGamepadDebug)
     	    {
				Log.d(Cocos2dxGLSurfaceView.TAG, String.format("onKeyDown %d - Id = %d Hash = %x",
						pKeyCode,
						pDeviceId,
						pDeviceHash
						));
     	    }
				
			this.queueEvent(new Runnable() {
				@Override
				public void run() {
					Cocos2dxGLSurfaceView.this.mCocos2dxRenderer.handleKeyDown(pKeyCode, pDeviceId, pDeviceHash);
				}
			});
				
			return true;
		}
		
		return super.onKeyDown(pKeyCode, pKeyEvent);
	}
	
	@Override
	public boolean onKeyUp(final int pKeyCode, final KeyEvent pKeyEvent) {
		
		// Ignore repeated keys
		if (pKeyEvent.getRepeatCount() != 0)
			return true;

		if (shouldConsumeKeyEvent(pKeyCode, pKeyEvent)) 
		{
			final int pDeviceId = getDeviceId(pKeyEvent);
			final int pDeviceHash = getDeviceHash(pKeyEvent);
			
     	    if (mDisplayGamepadDebug)
     	    {
				Log.d(Cocos2dxGLSurfaceView.TAG, String.format("onKeyUp %d - Id = %d Hash = %d",
						pKeyCode,
						pDeviceId,
						pDeviceHash
						));
     	    }
			
			this.queueEvent(new Runnable() {
				@Override
				public void run() {
					Cocos2dxGLSurfaceView.this.mCocos2dxRenderer.handleKeyUp(pKeyCode, pDeviceId, pDeviceHash);
				}
			});
			return true;
		}
		
		return super.onKeyUp(pKeyCode, pKeyEvent);
	}

	// ===========================================================
	// Methods
	// ===========================================================

	// ===========================================================
	// Inner and Anonymous Classes
	// ===========================================================

	public static void openIMEKeyboard() {
		final Message msg = new Message();
		msg.what = Cocos2dxGLSurfaceView.HANDLER_OPEN_IME_KEYBOARD;
		msg.obj = Cocos2dxGLSurfaceView.mCocos2dxGLSurfaceView.getContentText();
		Cocos2dxGLSurfaceView.sHandler.sendMessage(msg);
	}

	public static void closeIMEKeyboard() {
		final Message msg = new Message();
		msg.what = Cocos2dxGLSurfaceView.HANDLER_CLOSE_IME_KEYBOARD;
		Cocos2dxGLSurfaceView.sHandler.sendMessage(msg);
	}

	public void insertText(final String pText) {
		this.queueEvent(new Runnable() {
			@Override
			public void run() {
				Cocos2dxGLSurfaceView.this.mCocos2dxRenderer.handleInsertText(pText);
			}
		});
	}

	public void deleteBackward() {
		this.queueEvent(new Runnable() {
			@Override
			public void run() {
				Cocos2dxGLSurfaceView.this.mCocos2dxRenderer.handleDeleteBackward();
			}
		});
	}

	private static void dumpMotionEvent(final MotionEvent event) {
		final String names[] = { "DOWN", "UP", "MOVE", "CANCEL", "OUTSIDE", "POINTER_DOWN", "POINTER_UP", "7?", "8?", "9?" };
		final StringBuilder sb = new StringBuilder();
		final int action = event.getAction();
		final int actionCode = action & MotionEvent.ACTION_MASK;
		sb.append("event ACTION_").append(names[actionCode]);
		if (actionCode == MotionEvent.ACTION_POINTER_DOWN || actionCode == MotionEvent.ACTION_POINTER_UP) {
			sb.append("(pid ").append(action >> MotionEvent.ACTION_POINTER_ID_SHIFT);
			sb.append(")");
		}
		sb.append("[");
		for (int i = 0; i < event.getPointerCount(); i++) {
			sb.append("#").append(i);
			sb.append("(pid ").append(event.getPointerId(i));
			sb.append(")=").append((int) event.getX(i));
			sb.append(",").append((int) event.getY(i));
			if (i + 1 < event.getPointerCount()) {
				sb.append(";");
			}
		}
		sb.append("]");
		Log.d(Cocos2dxGLSurfaceView.TAG, sb.toString());
	}
}
