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

#include "CCGamepadDispatcher.h"
#include "support/data_support/ccCArray.h"

NS_CC_BEGIN

//------------------------------------------------------------------
//
// CCGamepadDispatcher
//
//------------------------------------------------------------------
CCGamepadDispatcher::CCGamepadDispatcher()
: m_bLocked(false)
, m_bToAdd(false)
, m_bToRemove(false)
{
    m_pDelegates = CCArray::create();
    m_pDelegates->retain();

    m_pHandlersToAdd    = ccCArrayNew(8);
    m_pHandlersToRemove = ccCArrayNew(8);
}

CCGamepadDispatcher::~CCGamepadDispatcher()
{
    CC_SAFE_RELEASE(m_pDelegates);
    if (m_pHandlersToAdd)
    {
        ccCArrayFree(m_pHandlersToAdd);
    }
    
    if (m_pHandlersToRemove)
    {
        ccCArrayFree(m_pHandlersToRemove);
    }    
}

void CCGamepadDispatcher::removeDelegate(CCGamepadDelegate* pDelegate)
{
    if (!pDelegate)
    {
        return;
    }
    if (! m_bLocked)
    {
        forceRemoveDelegate(pDelegate);
    }
    else
    {
        ccCArrayAppendValue(m_pHandlersToRemove, pDelegate);
        m_bToRemove = true;
    }
}

void CCGamepadDispatcher::addDelegate(CCGamepadDelegate* pDelegate)
{
    if (!pDelegate)
    {
        return;
    }

    if (! m_bLocked)
    {
        forceAddDelegate(pDelegate);
    }
    else
    {
        ccCArrayAppendValue(m_pHandlersToAdd, pDelegate);
        m_bToAdd = true;
    }
}

void CCGamepadDispatcher::forceAddDelegate(CCGamepadDelegate* pDelegate)
{
    CCGamepadHandler* pHandler = CCGamepadHandler::handlerWithDelegate(pDelegate);

    if (pHandler)
    {
        m_pDelegates->addObject(pHandler);
    }
}

void CCGamepadDispatcher::forceRemoveDelegate(CCGamepadDelegate* pDelegate)
{
    CCGamepadHandler* pHandler = NULL;
    CCObject* pObj = NULL;
    CCARRAY_FOREACH(m_pDelegates, pObj)
    {
        pHandler = (CCGamepadHandler*)pObj;
        if (pHandler && pHandler->getDelegate() == pDelegate)
        {
            m_pDelegates->removeObject(pHandler);
            break;
        }
    }
}

bool CCGamepadDispatcher::dispatchGamepadAxisMSG(ccGamepadAxisMSGType eType, float fValueX, float fValueY, int nDeviceID, int nDeviceHash)
{
    CCLog("dispatchGamepadAxisMSG");

    CCGamepadHandler*  pHandler = NULL;
    CCGamepadDelegate* pDelegate = NULL;

    m_bLocked = true;

    if (m_pDelegates->count() > 0)
    {
        CCObject* pObj = NULL;
        CCARRAY_FOREACH(m_pDelegates, pObj)
        {
            CC_BREAK_IF(!pObj);

            pHandler = (CCGamepadHandler*)pObj;
            pDelegate = pHandler->getDelegate();

            pDelegate->gamepadAxisMoved(eType, fValueX, fValueY, nDeviceID, nDeviceHash);
        }
    }

    m_bLocked = false;
    if (m_bToRemove)
    {
        m_bToRemove = false;
        for (unsigned int i = 0; i < m_pHandlersToRemove->num; ++i)
        {
            forceRemoveDelegate((CCGamepadDelegate*)m_pHandlersToRemove->arr[i]);
        }
        ccCArrayRemoveAllValues(m_pHandlersToRemove);
    }

    if (m_bToAdd)
    {
        m_bToAdd = false;
        for (unsigned int i = 0; i < m_pHandlersToAdd->num; ++i)
        {
            forceAddDelegate((CCGamepadDelegate*)m_pHandlersToAdd->arr[i]);
        }
        ccCArrayRemoveAllValues(m_pHandlersToAdd);
    }

    return true;
}

bool CCGamepadDispatcher::dispatchGamepadBtnMSG(ccGamepadBtnMSGType eType, int nKeyCode, int nDeviceID, int nDeviceHash)
{
    CCLog("CCGamepadDispatcher::dispatchGamepadBtnMSG %d %d", eType, nKeyCode);
    CCGamepadHandler*  pHandler = NULL;
    CCGamepadDelegate* pDelegate = NULL;
    
    m_bLocked = true;
    
    if (m_pDelegates->count() > 0)
    {
        CCObject* pObj = NULL;
        CCARRAY_FOREACH(m_pDelegates, pObj)
        {
            CC_BREAK_IF(!pObj);
            
            pHandler = (CCGamepadHandler*)pObj;
            pDelegate = pHandler->getDelegate();
            
            pDelegate->gamepadBtn(eType, nKeyCode, nDeviceID, nDeviceHash);
        }
    }
    
    m_bLocked = false;
    if (m_bToRemove)
    {
        m_bToRemove = false;
        for (unsigned int i = 0; i < m_pHandlersToRemove->num; ++i)
        {
            forceRemoveDelegate((CCGamepadDelegate*)m_pHandlersToRemove->arr[i]);
        }
        ccCArrayRemoveAllValues(m_pHandlersToRemove);
    }
    
    if (m_bToAdd)
    {
        m_bToAdd = false;
        for (unsigned int i = 0; i < m_pHandlersToAdd->num; ++i)
        {
            forceAddDelegate((CCGamepadDelegate*)m_pHandlersToAdd->arr[i]);
        }
        ccCArrayRemoveAllValues(m_pHandlersToAdd);
    }
    
    return true;
}

NS_CC_END
