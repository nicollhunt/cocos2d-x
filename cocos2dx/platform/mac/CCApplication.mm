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

#import "CCApplication.h"
#import <Cocoa/Cocoa.h>
#include <algorithm>

#include "CCGeometry.h"
#include "CCDirector.h"
#import "CCDirectorCaller.h"

NS_CC_BEGIN

CCApplication* CCApplication::sm_pSharedApplication = 0;

CCApplication::CCApplication()
{
    CCAssert(! sm_pSharedApplication, "sm_pSharedApplication already exist");
    sm_pSharedApplication = this;
}

CCApplication::~CCApplication()
{
    CCAssert(this == sm_pSharedApplication, "sm_pSharedApplication != this");
    sm_pSharedApplication = 0;
}

int CCApplication::run()
{
    if (/*initInstance() &&*/ applicationDidFinishLaunching()) 
    {
        [[CCDirectorCaller sharedDirectorCaller] startMainLoop];
    }
    return 0;
}

void CCApplication::setAnimationInterval(double interval)
{
    [[CCDirectorCaller sharedDirectorCaller] setAnimationInterval: interval ];
}

TargetPlatform CCApplication::getTargetPlatform()
{
    return kTargetMacOS;
}

bool CCApplication::isTargetPlatform(TargetPlatform eType)
{
    return eType == kTargetMacOS;
}


/////////////////////////////////////////////////////////////////////////////////////////////////
// static member function
//////////////////////////////////////////////////////////////////////////////////////////////////

CCApplication* CCApplication::sharedApplication()
{
    CCAssert(sm_pSharedApplication, "sm_pSharedApplication not set");
    return sm_pSharedApplication;
}

BOOL checkLocaleIdentfier(NSString *localeIdentifier, const char *pszCode)
{
    int nCodeLength = strlen(pszCode);
    const char *pszLocaleIdentifier = [localeIdentifier UTF8String];
    return strncmp(pszLocaleIdentifier, pszCode, nCodeLength) == 0;
}

ccLanguageType CCApplication::getCurrentLanguage()
{
    // get the current language code.(such as English is "en", Chinese is "zh" and so on)
    NSString * languageCode = [[NSLocale currentLocale] localeIdentifier];

    ccLanguageType ret = kLanguageEnglish;
    if (checkLocaleIdentfier(languageCode, "zh"))
    {
        ret = kLanguageChinese;
    }
    else if ([languageCode isEqualToString:@"en_US"])
    {
        ret = kLanguageAmericanEnglish;
    }
    else if (checkLocaleIdentfier(languageCode, "en"))
    {
        ret = kLanguageEnglish;
    }
    else if (checkLocaleIdentfier(languageCode, "fr"))
    {
        ret = kLanguageFrench;
    }
    else if (checkLocaleIdentfier(languageCode, "it"))
    {
        ret = kLanguageItalian;
    }
    else if (checkLocaleIdentfier(languageCode, "de"))
    {
        ret = kLanguageGerman;
    }
    else if (checkLocaleIdentfier(languageCode, "es"))
    {
        ret = kLanguageSpanish;
    }
    else if (checkLocaleIdentfier(languageCode, "ru"))
    {
        ret = kLanguageRussian;
    }
    else if (checkLocaleIdentfier(languageCode, "ko"))
    {
        ret = kLanguageKorean;
    }
    else if (checkLocaleIdentfier(languageCode, "ja"))
    {
        ret = kLanguageJapanese;
    }
    else if (checkLocaleIdentfier(languageCode, "hu"))
    {
        ret = kLanguageHungarian;
    }
    else if (checkLocaleIdentfier(languageCode, "pl"))
    {
        ret = kLanguagePolish;
    }
    else if ([languageCode isEqualToString:@"pt_BR"])
    {
        ret = kLanguageBrazillianPortuguese;
    }

    return ret;
}

void CCApplication::setResourceRootPath(const std::string& rootResDir)
{
    m_resourceRootPath = rootResDir;
    std::replace(m_resourceRootPath.begin(), m_resourceRootPath.end(), '\\', '/');
    if (m_resourceRootPath[m_resourceRootPath.length() - 1] != '/')
    {
        m_resourceRootPath += '/';
    }
}

const std::string& CCApplication::getResourceRootPath(void)
{
    return m_resourceRootPath;
}

void CCApplication::setStartupScriptFilename(const std::string& startupScriptFile)
{
    m_startupScriptFilename = startupScriptFile;
    std::replace(m_startupScriptFilename.begin(), m_startupScriptFilename.end(), '\\', '/');
}

const std::string& CCApplication::getStartupScriptFilename(void)
{
    return m_startupScriptFilename;
}

NS_CC_END
