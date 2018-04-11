常见错误：多重证书



如果遇到多重证书的问题，AssertionError: Multiple codesigning fingerprints for identity: iPhone Developer 

可参考 http://ninjanetic.com/how-to-get-started-with-webrtc-and-ios-without-wasting-10-hours-of-your-life/ 

大概步骤：

1， 用 security find-identity 找到你想要的identify

2，在 src/chromium/src/build/common.gypi 里有一个CODE_SIGN_IDENTITY，

把里面的  'CODE_SIGN_IDENTITY[sdk=iphoneos*]': 'iPhone Developer' 修改一下，
比如修改成  'CODE_SIGN_IDENTITY[sdk=iphoneos*]': 'iPhone Developer: Taylor Wei (DUABQZJ9JG)'
3，重新执行 

webrtc/build/gyp_webrtc

ninja -C out_ios/Debug-iphoneos AppRTCDemo