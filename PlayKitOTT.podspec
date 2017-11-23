Pod::Spec.new do |s|
  
  s.name             = 'PlayKitOTT'
  s.version          = '1.0.0'
  s.summary          = 'PlayKitOTT -- OTT framework for iOS'
  s.homepage         = 'https://github.com/kaltura/playkit-ios-ott'
  s.license          = { :type => 'AGPLv3', :file => 'LICENSE' }
  s.author           = { 'Kaltura' => 'community@kaltura.com' }
  s.source           = { :git => 'https://github.com/kaltura/playkit-ios-ott.git', :tag => 'v' + s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files = 'Sources/**/*'
  s.dependency 'PlayKit/Core'
  s.dependency 'PlayKit/AnalyticsCommon'
  s.dependency 'PlayKitUtils'
end

