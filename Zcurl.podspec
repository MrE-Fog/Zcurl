#
# Be sure to run `pod lib lint Zcurl.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Zcurl'
  s.version          = '1.0.0'
  s.summary          = 'curl + openssl + nghttp2 + crypto'
  s.description      = <<-DESC
LIBCURL="7.83.1"        # https://curl.haxx.se/download.html
OPENSSL="1.1.1o"        # https://www.openssl.org/source/
NGHTTP2="1.47.0"        # https://nghttp2.org/
                       DESC
  s.homepage         = 'https://github.com/lZackx/Zcurl'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'lZackx' => 'lzackx@lzackx.com' }
  s.source           = { :git => 'https://github.com/lZackx/Zcurl.git', :tag => s.version.to_s }
  s.source_files = 'Zcurl/Classes/**/*'
  s.public_header_files = 'Zcurl/Classes/include/**/*'
  s.resource = 'Zcurl/Assets/**/*'
  s.vendored_frameworks = [
  'xcframework/libcurl.xcframework',
  'xcframework/libnghttp2.xcframework',
  'xcframework/libssl.xcframework',
  'xcframework/libcrypto.xcframework',
  ]
  s.libraries = [
  'z'
  ]
end
