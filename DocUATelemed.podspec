#
# Be sure to run `pod lib lint DocUATelemed.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DocUATelemed'
  s.version          = '0.2.4'
  s.summary          = 'Telemed library for DOCUA'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Karamzda/DocUATelemed'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Taras Zinchenko' => 't.zinchenko@orderry.com' }
  s.source           = { :git => 'https://github.com/Karamzda/docUATelemed.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '14.0'
  s.swift_versions = ['5.0']
  s.source_files = 'DocUATelemed/Classes/**/*'
#  s.frameworks = ['Quickblox', 'QuickbloxWebRTC']
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  #s.vendored_frameworks   = "QuickBlox/QuickBlox.framework"
  
#  s.resources = "DocUATelemed/Classes/sources/Chat/View/*.xib"
  s.static_framework = true
  s.requires_arc = true
  s.xcconfig = { "FRAMEWORK_SEARCH_PATHS" => "$(PODS_ROOT)/QuickBlox/" }
  s.prefix_header_contents = '#import <Quickblox/Quickblox.h>'
  
   s.resource_bundles = {
     'DocUATelemed' => ['DocUATelemed/Assets/**/*', 'DocUATelemed/Assets/Fonts/suisse/*', 'DocUATelemed/Classes/sources/Chat/View/*.xib', 'DocUATelemed/Classes/sources/Chat/*.xib']
   }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
   s.dependency 'Quickblox-WebRTC', '~> 2.8.1'
   s.dependency 'ChatLayout', '~> 1.2'
   s.dependency 'SnapKit', '~> 5.6'
   s.dependency 'Kingfisher', '~> 7.3'
   s.dependency 'DifferenceKit', '~> 1.3'
   s.dependency 'InputBarAccessoryView', '~> 5.5'
end
