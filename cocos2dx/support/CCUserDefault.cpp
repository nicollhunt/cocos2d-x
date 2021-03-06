/****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org

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
#include "CCUserDefault.h"
#include "platform/CCCommon.h"
#include "platform/CCFileUtils.h"
#include <libxml/parser.h>
#include <libxml/tree.h>

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "jni/Java_org_cocos2dx_lib_Cocos2dxHelper.h"
#endif

// root name of xml
#define USERDEFAULT_ROOT_NAME    "userDefaultRoot"

#define XML_FILE_NAME "UserDefault.xml"

using namespace std;

NS_CC_BEGIN

#if (CC_TARGET_PLATFORM != CC_PLATFORM_ANDROID)
static xmlDocPtr g_sharedDoc = NULL;

/**
 * define the functions here because we don't want to
 * export xmlNodePtr and other types in "CCUserDefault.h"
 */

static xmlNodePtr getXMLNodeForKey(const char* pKey, xmlNodePtr *rootNode)
{
    xmlNodePtr curNode = NULL;

    // check the key value
    if (! pKey)
    {
        return NULL;
    }

    do 
    {
        // get root node
        *rootNode = xmlDocGetRootElement(g_sharedDoc);
        if (NULL == *rootNode)
        {
            CCLog("read root node error");
            break;
        }

        // find the node
        curNode = (*rootNode)->xmlChildrenNode;
        while (NULL != curNode)
        {
            if (! xmlStrcmp(curNode->name, BAD_CAST pKey))
            {
                break;
            }

            curNode = curNode->next;
        }
    } while (0);

    return curNode;
}
#endif


static inline const char* getValueForKey(const char* pKey)
{
    const char* ret = NULL;
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    if (hasSharedPreferenceJNI(pKey))
        ret = getSharedPreferenceJNI(pKey);
#else

    xmlNodePtr rootNode;
    xmlNodePtr node = getXMLNodeForKey(pKey, &rootNode);

    // find the node
    if (node)
    {
        ret = (const char*)xmlNodeGetContent(node);
    }
#endif

    return ret;
}

static void setValueForKey(const char* pKey, const char* pValue)
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    setSharedPreferenceJNI(pKey, pValue);
#else
    xmlNodePtr rootNode;
    xmlNodePtr node;

    // check the params
    if (! pKey || ! pValue)
    {
        return;
    }

    // find the node
    node = getXMLNodeForKey(pKey, &rootNode);

    // if node exist, change the content
    if (node)
    {
        xmlNodeSetContent(node, BAD_CAST pValue);
    }
    else
    {
        if (rootNode)
        {
            // the node doesn't exist, add a new one
            // libxml in android doesn't support xmlNewTextChild, so use this approach
            xmlNodePtr tmpNode = xmlNewNode(NULL, BAD_CAST pKey);
            xmlNodePtr content = xmlNewText(BAD_CAST pValue);
            xmlAddChild(rootNode, tmpNode);
            xmlAddChild(tmpNode, content);
        }
    }
#endif
}

/**
 * implements of CCUserDefault
 */

CCUserDefault* CCUserDefault::m_spUserDefault = 0;
string CCUserDefault::m_sFilePath = string("");
bool CCUserDefault::m_sbIsFilePathInitialized = false;

/**
 * If the user invoke delete CCUserDefault::sharedUserDefault(), should set m_spUserDefault
 * to null to avoid error when he invoke CCUserDefault::sharedUserDefault() later.
 */
CCUserDefault::~CCUserDefault()
{
#if (CC_TARGET_PLATFORM != CC_PLATFORM_ANDROID)
    flush();
    if (g_sharedDoc)
    {
        xmlFreeDoc(g_sharedDoc);
        g_sharedDoc = NULL;
    }
#endif


    m_spUserDefault = NULL;
}

CCUserDefault::CCUserDefault()
{
#if (CC_TARGET_PLATFORM != CC_PLATFORM_ANDROID)

    const char *filename = getXMLFilePath().c_str();
    
    unsigned long nSize;
    unsigned char* pBuffer = CCFileUtils::sharedFileUtils()->getFileData(filename, "rb", &nSize);
    
    g_sharedDoc = xmlReadFile(filename, "utf-8", XML_PARSE_RECOVER);
#endif
}

void CCUserDefault::purgeSharedUserDefault()
{
    CC_SAFE_DELETE(m_spUserDefault);
    m_spUserDefault = NULL;
}

 bool CCUserDefault::getBoolForKey(const char* pKey)
 {
     return getBoolForKey(pKey, false);
 }

bool CCUserDefault::getBoolForKey(const char* pKey, bool defaultValue)
{
    const char* value = getValueForKey(pKey);
    bool ret = defaultValue;

    if (value)
    {
        ret = (! strcmp(value, "true"));
#if (CC_TARGET_PLATFORM != CC_PLATFORM_ANDROID)
	xmlFree((void*)value);
#endif

    }

    return ret;
}

int CCUserDefault::getIntegerForKey(const char* pKey)
{
    return getIntegerForKey(pKey, 0);
}

int CCUserDefault::getIntegerForKey(const char* pKey, int defaultValue)
{
    const char* value = getValueForKey(pKey);
    int ret = defaultValue;

    if (value)
    {
        ret = atoi(value);
#if (CC_TARGET_PLATFORM != CC_PLATFORM_ANDROID)
	xmlFree((void*)value);
#endif

    }

    return ret;
}

float CCUserDefault::getFloatForKey(const char* pKey)
{
    return getFloatForKey(pKey, 0.0f);
}

float CCUserDefault::getFloatForKey(const char* pKey, float defaultValue)
{
    float ret = (float)getDoubleForKey(pKey, (double)defaultValue);
 
    return ret;
}

double  CCUserDefault::getDoubleForKey(const char* pKey)
{
    return getDoubleForKey(pKey, 0.0);
}

double CCUserDefault::getDoubleForKey(const char* pKey, double defaultValue)
{
    const char* value = getValueForKey(pKey);
    double ret = defaultValue;

    if (value)
    {
        ret = atof(value);
#if (CC_TARGET_PLATFORM != CC_PLATFORM_ANDROID)
	xmlFree((void*)value);
#endif
    }

    return ret;
}

std::string CCUserDefault::getStringForKey(const char* pKey)
{
    return getStringForKey(pKey, "");
}

string CCUserDefault::getStringForKey(const char* pKey, const std::string & defaultValue)
{
    const char* value = getValueForKey(pKey);
    string ret = defaultValue;

    if (value)
    {
        ret = string(value);
#if (CC_TARGET_PLATFORM != CC_PLATFORM_ANDROID)
        xmlFree((void*)value);
#endif
    }

    return ret;
}

void CCUserDefault::setBoolForKey(const char* pKey, bool value)
{
    // save bool value as string

    if (true == value)
    {
        setStringForKey(pKey, "true");
    }
    else
    {
        setStringForKey(pKey, "false");
    }
}

void CCUserDefault::setIntegerForKey(const char* pKey, int value)
{
    // check key
    if (! pKey)
    {
        return;
    }

    // format the value
    char tmp[50];
    memset(tmp, 0, 50);
    sprintf(tmp, "%d", value);

    setValueForKey(pKey, tmp);
}

void CCUserDefault::setFloatForKey(const char* pKey, float value)
{
    setDoubleForKey(pKey, value);
}

void CCUserDefault::setDoubleForKey(const char* pKey, double value)
{
    // check key
    if (! pKey)
    {
        return;
    }

    // format the value
    char tmp[50];
    memset(tmp, 0, 50);
    sprintf(tmp, "%f", value);

    setValueForKey(pKey, tmp);
}

void CCUserDefault::setStringForKey(const char* pKey, const std::string & value)
{
    // check key
    if (! pKey)
    {
        return;
    }

    setValueForKey(pKey, value.c_str());
}

CCUserDefault* CCUserDefault::sharedUserDefault()
{
#if (CC_TARGET_PLATFORM != CC_PLATFORM_ANDROID)
    initXMLFilePath();

    // only create xml file one time
    // the file exists after the program exit
    if ((! isXMLFileExist()) && (! createXMLFile()))
    {
        return NULL;
    }
#endif

    if (! m_spUserDefault)
    {
        m_spUserDefault = new CCUserDefault();
    }

    return m_spUserDefault;
}

#if (CC_TARGET_PLATFORM != CC_PLATFORM_ANDROID)
bool CCUserDefault::isXMLFileExist()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || \
     CC_TARGET_PLATFORM == CC_PLATFORM_OUYA || \
     CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    checkForCacheVersion();
#endif

    FILE *fp = fopen(m_sFilePath.c_str(), "r");
    bool bRet = false;

    if (fp)
    {
        bRet = true;
        fclose(fp);
    }

    return bRet;
}

void CCUserDefault::checkForCacheVersion()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || \
CC_TARGET_PLATFORM == CC_PLATFORM_OUYA || \
CC_TARGET_PLATFORM == CC_PLATFORM_IOS)

    // Copy any existing defaults file from the cache directory
    string sCachePath = CCFileUtils::sharedFileUtils()->getWriteablePath() + XML_FILE_NAME;
    string sDocumentsPath = CCFileUtils::sharedFileUtils()->getDocumentPath() + XML_FILE_NAME;
    
    FILE *fp = fopen(sCachePath.c_str(), "r");
    if (fp != NULL)
    {
        unsigned long nSize;
        unsigned char *pBuffer;
        
        // Read in existing file
        fseek(fp,0,SEEK_END);
        nSize = ftell(fp);
        fseek(fp,0,SEEK_SET);
        pBuffer = (unsigned char *)malloc(nSize);
        nSize = fread(pBuffer, sizeof(unsigned char), nSize, fp);
        fclose(fp);
        
        // Save to documents directory
        fp = fopen(sDocumentsPath.c_str(), "w");
        if (fp)
        {
            fwrite((void *)pBuffer, nSize, 1, fp);
            fclose(fp);
            
            // Delete cache file
            remove(sCachePath.c_str());
        }
        free(pBuffer);
    }
#endif
}

void CCUserDefault::initXMLFilePath()
{
    if (! m_sbIsFilePathInitialized)
    {
        m_sFilePath += CCFileUtils::sharedFileUtils()->getDocumentPath() + XML_FILE_NAME;
        m_sbIsFilePathInitialized = true;
    }
}

// create new xml file
bool CCUserDefault::createXMLFile()
{
    bool bRet = false;
    xmlDocPtr doc = NULL;

    do 
    {
        // new doc
        doc = xmlNewDoc(BAD_CAST"1.0");
        if (doc == NULL)
        {
            CCLog("can not create xml doc");
            break;
        }

        // new root node
        xmlNodePtr rootNode = xmlNewNode(NULL, BAD_CAST USERDEFAULT_ROOT_NAME);
        if (rootNode == NULL)
        {
            CCLog("can not create root node");
            break;
        }

        // set root node
        xmlDocSetRootElement(doc, rootNode);

        // save xml file
        xmlSaveFile(m_sFilePath.c_str(), doc);

        bRet = true;
    } while (0);

    // if doc is not null, free it
    if (doc)
    {
        xmlFreeDoc(doc);
    }

    return bRet;
}

const string& CCUserDefault::getXMLFilePath()
{
    return m_sFilePath;
}

void CCUserDefault::flush()
{
    // save to file
    if (g_sharedDoc)
    {
	// NDH - Made this a bit more robust in case computer crashes during save
	std::string filename = CCUserDefault::sharedUserDefault()->getXMLFilePath();
	std::string temp_filename = filename + "_TEMP";
	xmlSaveFile(temp_filename.c_str(), g_sharedDoc);
	remove(filename.c_str());
	rename(temp_filename.c_str(), filename.c_str());
    }
}
#else
const string& CCUserDefault::getXMLFilePath()
{
    return NULL;
}
void CCUserDefault::flush()
{
}
#endif

NS_CC_END
