Pod::Spec.new do |s|
  s.name             = "PIVideoPlayer"
  s.version          = "0.1.3"
  s.summary          = "A custom wrapper around AVFoundation for playing silent video files without any chrome."
  s.description      = <<-DESC
                       This is a custom implementation of a video player that provides no user interface elements around. It provides both a full-screen window implementation as well as a simple UIView implementation.
                       DESC
  s.homepage         = "https://github.com/prolificinteractive/PIVideoPlayer"
  s.license          = 'MIT'
  s.author           = { "Christopher Jones" => "chris.jones@haud.co" }
  s.source           = { :git => "https://github.com/prolificinteractive/PIVideoPlayer.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
end
