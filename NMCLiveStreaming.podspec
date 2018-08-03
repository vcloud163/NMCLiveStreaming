Pod::Spec.new do |s|
  s.name         = "NMCLiveStreaming"
  s.version      = "3.1.1"
  s.summary      = "Netease NMCLiveStreaming Framework"
  s.homepage     = "http://github.com/vcloud163" 
  s.license     = { :type => "MIT", :file => "LICENSE" }
  s.authors      = "Netease VCloud Team" 
 # s.source       = { :http => "http://yx-web.nosdn.127.net/package/LiveStreaming_iOS_SDK_V#{s.version}.zip"}
  s.source       = { :git => "https://github.com/vcloud163/NMCLiveStreaming.git", :tag => "#{s.version}" }
  s.platform     = :ios, '8.0'
 # s.frameworks =  'AudioToolbox', 'VideoToolbox' 
 # s.libraries  = 'sqlite3.0', 'z.1', 'c++', 'resolv'
  s.resources    = '**/NMCLiveStreaming/NMCVideoFilter.bundle' 
  s.ios.vendored_frameworks = '**/NMCLiveStreaming/NMCLiveStreaming.framework'
end
