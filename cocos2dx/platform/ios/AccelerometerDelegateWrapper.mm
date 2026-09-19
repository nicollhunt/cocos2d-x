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

#import "AccelerometerDelegateWrapper.h"
#import <CoreMotion/CoreMotion.h>

@interface AccelerometerDispatcher ()
{
    CMMotionManager *_motionManager;
    NSOperationQueue *_motionQueue;
}

@end

@implementation AccelerometerDispatcher

static AccelerometerDispatcher* s_pAccelerometerDispatcher;

@synthesize delegate_;
@synthesize acceleration_;

+ (id) sharedAccelerometerDispather
{
    if (s_pAccelerometerDispatcher == nil) {
        s_pAccelerometerDispatcher = [[self alloc] init];
    }
    
    return s_pAccelerometerDispatcher;
}

- (id) init
{
    acceleration_ = new cocos2d::CCAcceleration();
    return self;
}

- (void) dealloc
{
    s_pAccelerometerDispatcher = 0;
    delegate_ = 0;
    delete acceleration_;
    [super dealloc];
}

- (void) addDelegate: (cocos2d::CCAccelerometerDelegate *) delegate
{
    delegate_ = delegate;

    if (delegate_)
    {
        _motionQueue = [[NSOperationQueue alloc] init];
        _motionQueue.maxConcurrentOperationCount = 1;
        _motionQueue.name = @"com.cocos2dx.accelerometer";

        _motionManager = [[CMMotionManager alloc] init];
        if (_motionManager.accelerometerAvailable)
        {
            if (_motionManager.accelerometerUpdateInterval <= 0)
            {
                _motionManager.accelerometerUpdateInterval = 1.0 / 60.0;
            }
            [_motionManager startAccelerometerUpdatesToQueue:_motionQueue withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                [self accelerometer:accelerometerData didAccelerate:accelerometerData];
            }];
        }
        else
        {
            delegate_ = 0;
        }
    }
    else
    {
        [_motionManager stopAccelerometerUpdates];
        _motionManager = nil;
        _motionQueue = nil;
    }
}

-(void) setAccelerometerInterval:(float)interval
{
    if (_motionManager)
    {
        _motionManager.accelerometerUpdateInterval = interval;
    }
}

- (void)accelerometer:(CMAccelerometerData *)accelerometer didAccelerate:(CMAccelerometerData *)acceleration
{
    if (! delegate_)
    {
        return;
    }

    acceleration_->x = acceleration.acceleration.x;
    acceleration_->y = acceleration.acceleration.y;
    acceleration_->z = acceleration.acceleration.z;
    acceleration_->timestamp = acceleration.timestamp;
    
    double tmp = acceleration_->x;
    
    switch ([[UIApplication sharedApplication] statusBarOrientation]) 
    {
    case UIInterfaceOrientationLandscapeRight:
        acceleration_->x = -acceleration_->y;
        acceleration_->y = tmp;
        break;
        
    case UIInterfaceOrientationLandscapeLeft:
        acceleration_->x = acceleration_->y;
        acceleration_->y = -tmp;
        break;
        
    case UIInterfaceOrientationPortraitUpsideDown:
        acceleration_->x = -acceleration_->y;
        acceleration_->y = -tmp;
        break;
            
    case UIInterfaceOrientationPortrait:
        break;
    }
    
    delegate_->didAccelerate(acceleration_);
}

@end

