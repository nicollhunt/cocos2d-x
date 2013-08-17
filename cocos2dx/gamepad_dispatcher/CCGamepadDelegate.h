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

#ifndef __CCGAMEPAD_DELEGATE_H__
#define __CCGAMEPAD_DELEGATE_H__


#include "cocoa/CCObject.h"

NS_CC_BEGIN

typedef enum{
	
    kTypeGamepadBtnUp = 0,
    kTypeGamepadBtnDown,

} ccGamepadBtnMSGType;

typedef enum{
	
    kTypeGamepadBAxis_LStick,
    kTypeGamepadBAxis_RStick,
    kTypeGamepadBAxis_Triggers,
} ccGamepadAxisMSGType;

/**
 * @addtogroup input
 * @{
 */

class CC_DLL CCGamepadDelegate
{
public:
    
    // Axis movement
    virtual void gamepadAxisMoved(ccGamepadAxisMSGType eType, float fValueX, float fValueY, int nDeviceID, int nDeviceHash) {}
    
    // Button down/up
    virtual void gamepadBtn(ccGamepadBtnMSGType eType, int nKeyCode, int nDeviceID, int nDeviceHash) {}

};

/**
@brief
CCGamepadHandler
Object than contains the CCGamepadDelegate.
*/
class CC_DLL CCGamepadHandler : public CCObject
{
public:
    virtual ~CCGamepadHandler(void);

    /** delegate */
    CCGamepadDelegate* getDelegate();
    void setDelegate(CCGamepadDelegate *pDelegate);

    /** initializes a CCGamepadHandler with a delegate */
    virtual bool initWithDelegate(CCGamepadDelegate *pDelegate);

public:
    /** allocates a CCGamepadHandler with a delegate */
    static CCGamepadHandler* handlerWithDelegate(CCGamepadDelegate *pDelegate);

protected:
    CCGamepadDelegate* m_pDelegate;
};

// end of input group
/// @} 

NS_CC_END

#endif // __CCGAMEPAD_DELEGATE_H__
