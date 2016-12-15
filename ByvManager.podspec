#
# Be sure to run `pod lib lint ByvManager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ByvManager'
  s.version          = '0.1.1'
  s.summary          = 'A short description of ByvManager.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/byvapps/ByvManager'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Adrian' => 'adrian@byvapps.com' }
  s.source           = { :git => 'https://github.com/byvapps/ByvManager', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/byvapps'

  s.ios.deployment_target = '9.0'

  s.source_files = 'ByvManager/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ByvManager' => ['ByvManager/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'

  s.dependency 'ByvUtils'
  s.dependency 'Alamofire', '~> 4.0'
  s.dependency 'SwiftyJSON'
  s.dependency 'SVProgressHUD'
  # s.dependency 'Socket.IO-Client-Swift', '~> 8.1.1' # Or latest version

end
