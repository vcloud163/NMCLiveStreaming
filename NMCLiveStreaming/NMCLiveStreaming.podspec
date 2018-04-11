Pod::Spec.new do |s|
  s.name         = "NMCLiveStreaming"
  s.version      = "0.0.1"
  s.summary      = "Netease NMCLiveStreaming Framework"
  s.homepage     = "http://netease.im" 
 # s.license      = { :"type" => "Copyright", :"text" => " Copyright 2018 Netease "} 
  s.license     = { :type => "MIT", :file => "LICENSE" }
  s.authors      = "Netease VCloud Team" 
 # s.source       = { :http => "http://yx-web.nosdn.127.net/package/LiveStreaming_iOS_SDK_V#{s.version}.zip"}
  s.source       = { :git => "https://github.com/vcloud163/NMCLiveStreaming.git", :tag => "#{s.version}" }
  s.platform     = :ios, '7.0'
 # s.source_files = "**/header/*.h"
 # s.vendored_libraries = '**/lib/*.a' 
 # s.frameworks =  'AudioToolbox', 'VideoToolbox' 
 # s.libraries  = 'sqlite3.0', 'z.1', 'c++', 'resolv'
  s.resources    = '**/NMCVideoFilter.bundle' 
# s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
end
