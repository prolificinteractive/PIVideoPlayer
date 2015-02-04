// Copyright (c) 2015 Prolific Interactive
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <UIKit/UIKit.h>
#import "PIVideoView.h"

@class PIVideoPlayerWindow;

@protocol PIVideoPlayerWindowDelegate <NSObject>

@required
/**
 *  Alerts the delegate that the video player has finished playing the current video.
 *
 *  @param window
 *      The current instance of the PIVideoPlayerWindow.
 */
- (void)videoPlayerWindowDidFinishPlaying:(PIVideoPlayerWindow *)window;

@end

/**
 *  Handles the playing of a single-loop full screen video.
 */
@interface PIVideoPlayerWindow : UIWindow <PIVideoViewDelegate>

/**
 *  The delegate for the video player window.
 */
@property (nonatomic, weak) id <PIVideoPlayerWindowDelegate> videoPlayerWindowDelegate;

/**
 *  Loads and starts playing the video with the specified name and type. Note that it is assumed that the file is found in the main NSBundle.
 *
 *  @param videoName
 *      The name of the video file.
 *
 *  @param type
 *      The type of the video file.
 */
- (void)playVideoNamed:(NSString *)videoName
                ofType:(NSString *)type;

/**
 *  Loads and starts playing the video with the specified absolute path
 *
 *  @param videoPath
 *      The absolute path of the video
 */
- (void)playVideoAtPath:(NSString *)videoPath;

/**
 *  Loads and starts playing the video with the specified URL
 *
 *  @param URL
 *      The URL of the video to start playing.
 */
- (void)playVideoWithURL:(NSURL *)URL;

@end
