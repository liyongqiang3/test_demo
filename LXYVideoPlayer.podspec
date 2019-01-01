Pod::Spec.new do |s|
  s.name             = 'LXYVideoPlayer'
  s.version          = '0.0.1'
  s.summary          = 'A video player for iOS platform.'

  s.description      = <<-DESC
A video player for iOS platform, functions include: player basic control, video cache while playing, prefetching, and other utilities.
                       DESC

  s.homepage         = 'http://localhost/LXYVideoPlayer'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'LXY' => 'LXY' }
  s.source           = { :git => 'git@localhost/LXYVideoPlayer.git', :tag => s.version.to_s }

  s.platform = :ios, '7.0'
  s.ios.deployment_target = '7.0'
  s.requires_arc = true

  s.default_subspec = 'core'


   s.subspec 'core' do |ss|
    ss.source_files = [
    'LXYVideoPlayer/Classes/*.{h,m}',
    'LXYVideoPlayer/Classes/**/*.{h,m}'
    ]

    ss.public_header_files = [
    'LXYVideoPlayer/Classes/LXYVideoPlayer.h',
    'LXYVideoPlayer/Classes/Prefetch/LXYVideoPrefetchTaskManager.h',
    'LXYVideoPlayer/Classes/Prefetch/LXYVideoPrefetchHitRecorder.h',
    'LXYVideoPlayer/Classes/Play/LXYVideoPlayerController.h',
    'LXYVideoPlayer/Classes/Play/LXYVideoPlayerController+PlayControl.h',
    'LXYVideoPlayer/Classes/Play/LXYVideoPlayerControllerDelegate.h',
    'LXYVideoPlayer/Classes/Play/LXYVideoPlayerEnumDefines.h',
    'LXYVideoPlayer/Classes/Network/LXYVideoNetworkDelegate.h',
    'LXYVideoPlayer/Classes/Cache/LXYVideoDiskCache.h',
    'LXYVideoPlayer/Classes/Cache/LXYVideoDiskCacheConfiguration.h']

    ss.exclude_files = ['LXYVideoPlayer/Classes/Log/DDLog/*.{h,m}','LXYVideoPlayer/Classes/Log/System/*.{h,m}']


   end

  s.subspec 'SYSLog' do |ss|
    ss.source_files = ['LXYVideoPlayer/Classes/Log/System/*.{h,m}']
    ss.public_header_files = ['LXYVideoPlayer/Classes/Log/LXYVideoLogger.h']

    ss.frameworks = 'Foundation'
  end

  s.subspec 'DDLog' do |ss|
    ss.source_files = ['LXYVideoPlayer/Classes/Log/DDLog/*.{h,m}']
    ss.public_header_files = ['LXYVideoPlayer/Classes/Log/LXYVideoLogger.h']

    ss.dependency 'CocoaLumberjack'
    ss.frameworks = 'Foundation'
  end

end
