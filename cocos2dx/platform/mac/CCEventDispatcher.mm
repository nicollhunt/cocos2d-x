/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

// Only compile this code on Mac. These files should not be included on your iOS project.
// But in case they are included, it won't be compiled.
#import <Availability.h>

#import "CCEventDispatcher.h"
#import "ccConfig.h"
#include "support/data_support/utlist.h"

#include "CCDirector.h"
#include "keyboard_dispatcher/CCKeyboardDispatcher.h"

//NS_CC_BEGIN;
static CCEventDispatcher *sharedDispatcher = nil;

#include <unordered_map>
#include <Carbon/Carbon.h>

static std::unordered_map<int, int> g_keyCodeMap;

USING_NS_CC;

void initKeycodeMap()
{
    g_keyCodeMap[kVK_Space] = KEY_SPACE;
    
    {
        /* Printable keys */
        g_keyCodeMap[kVK_Space ] = KEY_SPACE;
        //    g_keyCodeMap[kVK_ANSI_APOSTROPHE] = KEY_APOSTROPHE;
        g_keyCodeMap[kVK_ANSI_Comma] = KEY_COMMA;
        g_keyCodeMap[kVK_ANSI_Minus] = KEY_MINUS;
        g_keyCodeMap[kVK_ANSI_Period] = KEY_PERIOD;
        g_keyCodeMap[kVK_ANSI_Slash] = KEY_SLASH;
        g_keyCodeMap[kVK_ANSI_0] = KEY_0;
        g_keyCodeMap[kVK_ANSI_1] = KEY_1;
        g_keyCodeMap[kVK_ANSI_2] = KEY_2;
        g_keyCodeMap[kVK_ANSI_3] = KEY_3;
        g_keyCodeMap[kVK_ANSI_4] = KEY_4;
        g_keyCodeMap[kVK_ANSI_5] = KEY_5;
        g_keyCodeMap[kVK_ANSI_6] = KEY_6;
        g_keyCodeMap[kVK_ANSI_7] = KEY_7;
        g_keyCodeMap[kVK_ANSI_8] = KEY_8;
        g_keyCodeMap[kVK_ANSI_9] = KEY_9;
        g_keyCodeMap[kVK_ANSI_Semicolon] = KEY_SEMICOLON,
        g_keyCodeMap[kVK_ANSI_Equal] = KEY_EQUAL;
        g_keyCodeMap[kVK_ANSI_A] = KEY_A;
        g_keyCodeMap[kVK_ANSI_B] = KEY_B;
        g_keyCodeMap[kVK_ANSI_C] = KEY_C;
        g_keyCodeMap[kVK_ANSI_D] = KEY_D;
        g_keyCodeMap[kVK_ANSI_E] = KEY_E;
        g_keyCodeMap[kVK_ANSI_F] = KEY_F;
        g_keyCodeMap[kVK_ANSI_G] = KEY_G;
        g_keyCodeMap[kVK_ANSI_H] = KEY_H;
        g_keyCodeMap[kVK_ANSI_I] = KEY_I;
        g_keyCodeMap[kVK_ANSI_J] = KEY_J;
        g_keyCodeMap[kVK_ANSI_K] = KEY_K;
        g_keyCodeMap[kVK_ANSI_L] = KEY_L;
        g_keyCodeMap[kVK_ANSI_M] = KEY_M;
        g_keyCodeMap[kVK_ANSI_N] = KEY_N;
        g_keyCodeMap[kVK_ANSI_O] = KEY_O;
        g_keyCodeMap[kVK_ANSI_P] = KEY_P;
        g_keyCodeMap[kVK_ANSI_Q] = KEY_Q;
        g_keyCodeMap[kVK_ANSI_R] = KEY_R;
        g_keyCodeMap[kVK_ANSI_S] = KEY_S;
        g_keyCodeMap[kVK_ANSI_T] = KEY_T;
        g_keyCodeMap[kVK_ANSI_U] = KEY_U;
        g_keyCodeMap[kVK_ANSI_V] = KEY_V;
        g_keyCodeMap[kVK_ANSI_W] = KEY_W;
        g_keyCodeMap[kVK_ANSI_X] = KEY_X;
        g_keyCodeMap[kVK_ANSI_Y] = KEY_Y;
        g_keyCodeMap[kVK_ANSI_Z] = KEY_Z;
        g_keyCodeMap[kVK_ANSI_LeftBracket] = KEY_LEFT_BRACKET;
        g_keyCodeMap[kVK_ANSI_Backslash] = KEY_BACK_SLASH;
        g_keyCodeMap[kVK_ANSI_RightBracket] = KEY_RIGHT_BRACKET;
        g_keyCodeMap[kVK_ANSI_Grave] = KEY_GRAVE;
        //    g_keyCodeMap[kVK_ANSI_WORLD_1] = KEY_GRAVE;
        //    g_keyCodeMap[kVK_ANSI_WORLD_2] = KEY_NONE;
        
        /* Function keys */
        g_keyCodeMap[kVK_Escape] = KEY_ESCAPE;
        g_keyCodeMap[kVK_Return] = KEY_RETURN;
        g_keyCodeMap[kVK_Tab] = KEY_TAB;
        g_keyCodeMap[kVK_ForwardDelete] = KEY_BACKSPACE;
        //    g_keyCodeMap[kVK_ANSI_INSERT] = KEY_INSERT;
        g_keyCodeMap[kVK_Delete] = KEY_DELETE;
        g_keyCodeMap[kVK_RightArrow] = KEY_RIGHT_ARROW;
        g_keyCodeMap[kVK_LeftArrow] = KEY_LEFT_ARROW;
        g_keyCodeMap[kVK_DownArrow] = KEY_DOWN_ARROW;
        g_keyCodeMap[kVK_UpArrow] = KEY_UP_ARROW;
        g_keyCodeMap[kVK_PageUp] = KEY_KP_PG_UP;
        g_keyCodeMap[kVK_PageDown] = KEY_KP_PG_DOWN;
        g_keyCodeMap[kVK_Home] = KEY_KP_HOME;
        g_keyCodeMap[kVK_End] = KEY_END;
        g_keyCodeMap[kVK_CapsLock] = KEY_CAPS_LOCK;
        //    g_keyCodeMap[kVK_ANSI_SCROLL_LOCK] = KEY_SCROLL_LOCK;
        //    g_keyCodeMap[kVK_ANSI_NUM_LOCK] = KEY_NUM_LOCK;
        //    g_keyCodeMap[kVK_ANSI_PRINT_SCREEN] = KEY_PRINT;
        //    g_keyCodeMap[kVK_ANSI_PAUSE] = KEY_PAUSE;
        g_keyCodeMap[kVK_F1] = KEY_F1;
        g_keyCodeMap[kVK_F2] = KEY_F2;
        g_keyCodeMap[kVK_F3] = KEY_F3;
        g_keyCodeMap[kVK_F4] = KEY_F4;
        g_keyCodeMap[kVK_F5] = KEY_F5;
        g_keyCodeMap[kVK_F6] = KEY_F6;
        g_keyCodeMap[kVK_F7] = KEY_F7;
        g_keyCodeMap[kVK_F8] = KEY_F8;
        g_keyCodeMap[kVK_F9] = KEY_F9;
        g_keyCodeMap[kVK_F10] = KEY_F10;
        g_keyCodeMap[kVK_F11] = KEY_F11;
        g_keyCodeMap[kVK_F12] = KEY_F12;
        g_keyCodeMap[kVK_F13] = KEY_NONE;
        g_keyCodeMap[kVK_F14] = KEY_NONE;
        g_keyCodeMap[kVK_F15] = KEY_NONE;
        g_keyCodeMap[kVK_F16] = KEY_NONE;
        g_keyCodeMap[kVK_F17] = KEY_NONE;
        g_keyCodeMap[kVK_F18] = KEY_NONE;
        g_keyCodeMap[kVK_F19] = KEY_NONE;
        g_keyCodeMap[kVK_F20] = KEY_NONE;
        //    g_keyCodeMap[kVK_F21] = KEY_NONE;
        //    g_keyCodeMap[kVK_F22] = KEY_NONE;
        //    g_keyCodeMap[kVK_F23] = KEY_NONE;
        //    g_keyCodeMap[kVK_F24] = KEY_NONE;
        //    g_keyCodeMap[kVK_F25] = KEY_NONE;
        g_keyCodeMap[kVK_ANSI_Keypad0] = KEY_0;
        g_keyCodeMap[kVK_ANSI_Keypad1] = KEY_1;
        g_keyCodeMap[kVK_ANSI_Keypad2] = KEY_2;
        g_keyCodeMap[kVK_ANSI_Keypad3] = KEY_3;
        g_keyCodeMap[kVK_ANSI_Keypad4] = KEY_4;
        g_keyCodeMap[kVK_ANSI_Keypad5] = KEY_5;
        g_keyCodeMap[kVK_ANSI_Keypad6] = KEY_6;
        g_keyCodeMap[kVK_ANSI_Keypad7] = KEY_7;
        g_keyCodeMap[kVK_ANSI_Keypad8] = KEY_8;
        g_keyCodeMap[kVK_ANSI_Keypad9] = KEY_9;
        g_keyCodeMap[kVK_ANSI_KeypadDecimal] = KEY_PERIOD;
        g_keyCodeMap[kVK_ANSI_KeypadDivide] = KEY_KP_DIVIDE;
        g_keyCodeMap[kVK_ANSI_KeypadMultiply] = KEY_KP_MULTIPLY;
        g_keyCodeMap[kVK_ANSI_KeypadMinus] = KEY_KP_MINUS;
        g_keyCodeMap[kVK_ANSI_KeypadPlus] = KEY_KP_PLUS;
        g_keyCodeMap[kVK_ANSI_KeypadEnter] = KEY_KP_ENTER;
        g_keyCodeMap[kVK_ANSI_KeypadEquals] = KEY_EQUAL;
        g_keyCodeMap[kVK_Shift] = KEY_SHIFT;
        g_keyCodeMap[kVK_Control] = KEY_CTRL;
        //    g_keyCodeMap[kVK_ANSI_LEFT_ALT] = KEY_ALT;
        g_keyCodeMap[kVK_Option] = KEY_HYPER;
        g_keyCodeMap[kVK_RightShift] = KEY_SHIFT;
        g_keyCodeMap[kVK_RightControl] = KEY_CTRL;
        //    g_keyCodeMap[kVK_ANSI_RIGHT_ALT] = KEY_ALT;
        g_keyCodeMap[kVK_RightOption] = KEY_HYPER;
        //    g_keyCodeMap[kVK_ANSI_MENU] = KEY_MENU;
        //    g_keyCodeMap[kVK_ANSI_LAST] = KEY_NONE          }
    };
}


enum  {
	// mouse
	kCCImplementsMouseDown			= 1 << 0,
	kCCImplementsMouseMoved			= 1 << 1,
	kCCImplementsMouseDragged		= 1 << 2,	
	kCCImplementsMouseUp			= 1 << 3,
	kCCImplementsRightMouseDown		= 1 << 4,
	kCCImplementsRightMouseDragged	= 1 << 5,
	kCCImplementsRightMouseUp		= 1 << 6,
	kCCImplementsOtherMouseDown		= 1 << 7,
	kCCImplementsOtherMouseDragged	= 1 << 8,
	kCCImplementsOtherMouseUp		= 1 << 9,
	kCCImplementsScrollWheel		= 1 << 10,
	kCCImplementsMouseEntered		= 1 << 11,
	kCCImplementsMouseExited		= 1 << 12,

	kCCImplementsTouchesBegan		= 1 << 13,
	kCCImplementsTouchesMoved		= 1 << 14,
	kCCImplementsTouchesEnded		= 1 << 15,
	kCCImplementsTouchesCancelled	        = 1 << 16,

	// keyboard
	kCCImplementsKeyUp				= 1 << 0,
	kCCImplementsKeyDown			= 1 << 1,
	kCCImplementsFlagsChanged		= 1 << 2,
};


typedef struct _listEntry
{
	struct	_listEntry	*prev, *next;
	id					delegate;
	NSInteger			priority;
	NSUInteger			flags;
} tListEntry;


#if CC_DIRECTOR_MAC_USE_DISPLAY_LINK_THREAD

#define QUEUE_EVENT_MAX 128
struct _eventQueue {
	SEL		selector;
	NSEvent	*event;
};

static struct	_eventQueue eventQueue[QUEUE_EVENT_MAX];
static int		eventQueueCount;

#endif // CC_DIRECTOR_MAC_USE_DISPLAY_LINK_THREAD


@implementation CCEventDispatcher

@synthesize dispatchEvents=dispatchEvents_;


+(CCEventDispatcher*) sharedDispatcher
{
	@synchronized(self) {
		if (sharedDispatcher == nil)
			sharedDispatcher = [[self alloc] init]; // assignment not done here
	}
	return sharedDispatcher;
}

+(id) allocWithZone:(NSZone *)zone
{
	@synchronized(self) {
		NSAssert(sharedDispatcher == nil, @"Attempted to allocate a second instance of a singleton.");
		return [super allocWithZone:zone];
	}
	return nil; // on subsequent allocation attempts return nil
}

-(id) init
{
	if( (self = [super init]) )
	{
		// events enabled by default
		dispatchEvents_ = YES;

		// delegates
		keyboardDelegates_ = NULL;
		mouseDelegates_ = NULL;
                touchDelegates_ = NULL;
		
#if	CC_DIRECTOR_MAC_USE_DISPLAY_LINK_THREAD
		eventQueueCount = 0;
#endif
        
        // NDH - Use a standard mapping for all keyboards
        initKeycodeMap();
	}
	
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

#pragma mark CCEventDispatcher - add / remove delegates

-(void) addDelegate:(id)delegate priority:(NSInteger)priority flags:(NSUInteger)flags list:(tListEntry**)list
{
	tListEntry *listElement = (tListEntry *)malloc( sizeof(*listElement) );
	
	listElement->delegate = [delegate retain];
	listElement->priority = priority;
	listElement->flags = flags;
	listElement->next = listElement->prev = NULL;
	
	// empty list ?
	if( ! *list ) {
		DL_APPEND( *list, listElement );
		
	} else {
		BOOL added = NO;		
		
		for( tListEntry *elem = *list; elem ; elem = elem->next ) {
			if( priority < elem->priority ) {
				
				if( elem == *list )
					DL_PREPEND(*list, listElement);
				else {
					listElement->next = elem;
					listElement->prev = elem->prev;
					
					elem->prev->next = listElement;
					elem->prev = listElement;
				}
				
				added = YES;
				break;
			}
		}
		
		// Not added? priority has the higher value. Append it.
		if( !added )
			DL_APPEND(*list, listElement);
	}
}

-(void) removeDelegate:(id)delegate fromList:(tListEntry**)list
{
	tListEntry *entry, *tmp;
	
	// updates with priority < 0
	DL_FOREACH_SAFE( *list, entry, tmp ) {
		if( entry->delegate == delegate ) {
			DL_DELETE( *list, entry );
			[delegate release];
			free(entry);
			break;
		}
	}
}

-(void) removeAllDelegatesFromList:(tListEntry**)list
{
	tListEntry *entry, *tmp;

	DL_FOREACH_SAFE( *list, entry, tmp ) {
		DL_DELETE( *list, entry );
		free(entry);
	}
}


-(void) addMouseDelegate:(id<CCMouseEventDelegate>) delegate priority:(NSInteger)priority
{
	NSUInteger flags = 0;
	
	flags |= ( [delegate respondsToSelector:@selector(ccMouseDown:)] ? kCCImplementsMouseDown : 0 );
	flags |= ( [delegate respondsToSelector:@selector(ccMouseDragged:)] ? kCCImplementsMouseDragged : 0 );
	flags |= ( [delegate respondsToSelector:@selector(ccMouseMoved:)] ? kCCImplementsMouseMoved : 0 );
	flags |= ( [delegate respondsToSelector:@selector(ccMouseUp:)] ? kCCImplementsMouseUp : 0 );

	flags |= ( [delegate respondsToSelector:@selector(ccRightMouseDown:)] ? kCCImplementsRightMouseDown : 0 );
	flags |= ( [delegate respondsToSelector:@selector(ccRightMouseDragged:)] ? kCCImplementsRightMouseDragged : 0 );
	flags |= ( [delegate respondsToSelector:@selector(ccRightMouseUp:)] ? kCCImplementsRightMouseUp : 0 );

	flags |= ( [delegate respondsToSelector:@selector(ccOtherMouseDown:)] ? kCCImplementsOtherMouseDown : 0 );
	flags |= ( [delegate respondsToSelector:@selector(ccOtherMouseDragged:)] ? kCCImplementsOtherMouseDragged : 0 );
	flags |= ( [delegate respondsToSelector:@selector(ccOtherMouseUp:)] ? kCCImplementsOtherMouseUp : 0 );

	flags |= ( [delegate respondsToSelector:@selector(ccMouseEntered:)] ? kCCImplementsMouseEntered : 0 );
	flags |= ( [delegate respondsToSelector:@selector(ccMouseExited:)] ? kCCImplementsMouseExited : 0 );

	flags |= ( [delegate respondsToSelector:@selector(ccScrollWheel:)] ? kCCImplementsScrollWheel : 0 );

	[self addDelegate:delegate priority:priority flags:flags list:&mouseDelegates_];
}

-(void) removeMouseDelegate:(id) delegate
{
	[self removeDelegate:delegate fromList:&mouseDelegates_];
}

-(void) removeAllMouseDelegates
{
	[self removeAllDelegatesFromList:&mouseDelegates_];
}

-(void) addKeyboardDelegate:(id<CCKeyboardEventDelegate>) delegate priority:(NSInteger)priority
{
	NSUInteger flags = 0;
	
	flags |= ( [delegate respondsToSelector:@selector(ccKeyUp:)] ? kCCImplementsKeyUp : 0 );
	flags |= ( [delegate respondsToSelector:@selector(ccKeyDown:)] ? kCCImplementsKeyDown : 0 );
	flags |= ( [delegate respondsToSelector:@selector(ccFlagsChanged:)] ? kCCImplementsFlagsChanged : 0 );
	
	[self addDelegate:delegate priority:priority flags:flags list:&keyboardDelegates_];
}

-(void) removeKeyboardDelegate:(id) delegate
{
	[self removeDelegate:delegate fromList:&keyboardDelegates_];
}

-(void) removeAllKeyboardDelegates
{
	[self removeAllDelegatesFromList:&keyboardDelegates_];
}

-(void) addTouchDelegate:(id<CCTouchEventDelegate>) delegate priority:(NSInteger)priority
{
	NSUInteger flags = 0;
	
	flags |= ( [delegate respondsToSelector:@selector(ccTouchesBeganWithEvent:)] ? kCCImplementsTouchesBegan : 0 );
	flags |= ( [delegate respondsToSelector:@selector(ccTouchesMovedWithEvent:)] ? kCCImplementsTouchesMoved : 0 );
	flags |= ( [delegate respondsToSelector:@selector(ccTouchesEndedWithEvent:)] ? kCCImplementsTouchesEnded : 0 );
	flags |= ( [delegate respondsToSelector:@selector(ccTouchesCancelledWithEvent:)] ? kCCImplementsTouchesCancelled : 0 );
	
	[self addDelegate:delegate priority:priority flags:flags list:&touchDelegates_];
}

-(void) removeTouchDelegate:(id) delegate
{
	[self removeDelegate:delegate fromList:&touchDelegates_];
}

-(void) removeAllTouchDelegates
{
	[self removeAllDelegatesFromList:&touchDelegates_];
}


#pragma mark CCEventDispatcher - Mouse events
//
// Mouse events
//

//
// Left
//
- (void)mouseDown:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;

		DL_FOREACH_SAFE( mouseDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsMouseDown ) {
				void *swallows = [entry->delegate performSelector:@selector(ccMouseDown:) withObject:event];
				if( swallows )
					break;
			}
		}
	}
}

- (void)mouseMoved:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;
		
		DL_FOREACH_SAFE( mouseDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsMouseMoved ) {
				void *swallows = [entry->delegate performSelector:@selector(ccMouseMoved:) withObject:event];
				if( swallows )
					break;
			}
		}
	}
}

- (void)mouseDragged:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;
		
		DL_FOREACH_SAFE( mouseDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsMouseDragged ) {
				void *swallows = [entry->delegate performSelector:@selector(ccMouseDragged:) withObject:event];
				if( swallows )
					break;
			}
		}
	}
}

- (void)mouseUp:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;
		
		DL_FOREACH_SAFE( mouseDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsMouseUp ) {
				void *swallows = [entry->delegate performSelector:@selector(ccMouseUp:) withObject:event];
				if( swallows )
					break;
			}
		}
	}
}

//
// Mouse Right
//
- (void)rightMouseDown:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;
		
		DL_FOREACH_SAFE( mouseDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsRightMouseDown ) {
				void *swallows = [entry->delegate performSelector:@selector(ccRightMouseDown:) withObject:event];
				if( swallows )
					break;
			}
		}
	}
}

- (void)rightMouseDragged:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;
		
		DL_FOREACH_SAFE( mouseDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsRightMouseDragged ) {
				void *swallows = [entry->delegate performSelector:@selector(ccRightMouseDragged:) withObject:event];
				if( swallows )
					break;
			}
		}
	}
}

- (void)rightMouseUp:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;
		
		DL_FOREACH_SAFE( mouseDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsRightMouseUp ) {
				void *swallows = [entry->delegate performSelector:@selector(ccRightMouseUp:) withObject:event];
				if( swallows )
					break;
			}
		}
	}
}

//
// Mouse Other
//
- (void)otherMouseDown:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;
		
		DL_FOREACH_SAFE( mouseDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsOtherMouseDown ) {
				void *swallows = [entry->delegate performSelector:@selector(ccOtherMouseDown:) withObject:event];
				if( swallows )
					break;
			}
		}
	}
}

- (void)otherMouseDragged:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;
		
		DL_FOREACH_SAFE( mouseDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsOtherMouseDragged ) {
				void *swallows = [entry->delegate performSelector:@selector(ccOtherMouseDragged:) withObject:event];
				if( swallows )
					break;
			}
		}
	}
}

- (void)otherMouseUp:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;
		
		DL_FOREACH_SAFE( mouseDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsOtherMouseUp ) {
				void *swallows = [entry->delegate performSelector:@selector(ccOtherMouseUp:) withObject:event];
				if( swallows )
					break;
			}
		}
	}
}

//
// Scroll Wheel
//
- (void)scrollWheel:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;
		
		DL_FOREACH_SAFE( mouseDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsScrollWheel ) {
				void *swallows = [entry->delegate performSelector:@selector(ccScrollWheel:) withObject:event];
				if( swallows )
					break;
			}
		}
	}
}

//
// Mouse enter / exit
- (void)mouseExited:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;
		
		DL_FOREACH_SAFE( mouseDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsMouseEntered ) {
				void *swallows = [entry->delegate performSelector:@selector(ccMouseEntered:) withObject:event];
				if( swallows )
					break;
			}
		}
	}	
}

- (void)mouseEntered:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;
		
		DL_FOREACH_SAFE( mouseDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsMouseExited) {
				void *swallows = [entry->delegate performSelector:@selector(ccMouseExited:) withObject:event];
				if( swallows )
					break;
			}
		}
	}	
}


#pragma mark CCEventDispatcher - Keyboard events

// Keyboard events
- (void)keyDown:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;

      cocos2d::CCKeyboardDispatcher *kbDisp = cocos2d::CCDirector::sharedDirector()->getKeyboardDispatcher();
      kbDisp->dispatchKeyboardEvent(g_keyCodeMap[event.keyCode], true);
		DL_FOREACH_SAFE( keyboardDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsKeyDown ) {
				void *swallows = [entry->delegate performSelector:@selector(ccKeyDown:) withObject:event];
				if( swallows )
					break;
			}
		}
	}    
}

- (void)keyUp:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;
		
      cocos2d::CCKeyboardDispatcher *kbDisp = cocos2d::CCDirector::sharedDirector()->getKeyboardDispatcher();
      kbDisp->dispatchKeyboardEvent(g_keyCodeMap[event.keyCode], false);
		DL_FOREACH_SAFE( keyboardDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsKeyUp ) {
				void *swallows = [entry->delegate performSelector:@selector(ccKeyUp:) withObject:event];
				if( swallows )
					break;
			}
		}
	}
}

- (void)flagsChanged:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;
		
		DL_FOREACH_SAFE( keyboardDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsFlagsChanged ) {
				void *swallows = [entry->delegate performSelector:@selector(ccFlagsChanged:) withObject:event];
				if( swallows )
					break;
			}
		}
	}
}


#pragma mark CCEventDispatcher - Touch events

- (void)touchesBeganWithEvent:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;
		
		DL_FOREACH_SAFE( touchDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsTouchesBegan) {
				void *swallows = [entry->delegate performSelector:@selector(ccTouchesBeganWithEvent:) withObject:event];
				if( swallows )
					break;
			}
		}
	}	
}

- (void)touchesMovedWithEvent:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;
		
		DL_FOREACH_SAFE( touchDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsTouchesMoved) {
				void *swallows = [entry->delegate performSelector:@selector(ccTouchesMovedWithEvent:) withObject:event];
				if( swallows )
					break;
			}
		}
	}	
}

- (void)touchesEndedWithEvent:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;
		
		DL_FOREACH_SAFE( touchDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsTouchesEnded) {
				void *swallows = [entry->delegate performSelector:@selector(ccTouchesEndedWithEvent:) withObject:event];
				if( swallows )
					break;
			}
		}
	}	
}

- (void)touchesCancelledWithEvent:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;
		
		DL_FOREACH_SAFE( touchDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsTouchesCancelled) {
				void *swallows = [entry->delegate performSelector:@selector(ccTouchesCancelledWithEvent:) withObject:event];
				if( swallows )
					break;
			}
		}
	}	
}


#pragma mark CCEventDispatcher - queue events

#if CC_DIRECTOR_MAC_USE_DISPLAY_LINK_THREAD
-(void) queueEvent:(NSEvent*)event selector:(SEL)selector
{
	NSAssert( eventQueueCount < QUEUE_EVENT_MAX, @"CCEventDispatcher: recompile. Increment QUEUE_EVENT_MAX value");

	@synchronized (self) {
		eventQueue[eventQueueCount].selector = selector;
		eventQueue[eventQueueCount].event = [event copy];
		
		eventQueueCount++;
	}
}

-(void) dispatchQueuedEvents
{
	@synchronized (self) {
		for( int i=0; i < eventQueueCount; i++ ) {
			SEL sel = eventQueue[i].selector;
			NSEvent *event = eventQueue[i].event;
			
			[self performSelector:sel withObject:event];
			
			[event release];
		}
		
		eventQueueCount = 0;
	}
}
#endif // CC_DIRECTOR_MAC_USE_DISPLAY_LINK_THREAD

//NS_CC_END;
@end
