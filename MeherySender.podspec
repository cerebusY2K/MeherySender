#
# Be sure to run `pod lib lint MeherySender.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MeherySender'
  s.version          = '0.1.0'
  s.summary          = 'MeherySender is an SDK used by Mehery to send push notification to your device / customer devices.'
  s.swift_version = '5.0'
  s.ios.deployment_target = '12.0'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  MeherySender is an SDK used by Mehery to send push notification to your device / customer devices. TODO Add to example app
                       DESC

  s.homepage         = 'https://github.com/cerebusY2K/MeherySender'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ninjabase8085' => 'pranjal.7vyas@gmail.com' }
  s.source           = { :git => 'https://github.com/cerebusY2K/MeherySender.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
#  s.source_files = 'YourSDKName/*.{h,m,swift}'


  s.ios.deployment_target = '10.0'

  s.source_files = 'MeherySender/Classes/**/*'
  
  # s.resource_bundles = {
  #   'MeherySender' => ['MeherySender/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
