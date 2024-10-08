#
# Be sure to run `pod lib lint CommandBarIOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CommandBarIOS'
  s.version          = '1.1.9'
  s.summary          = 'HelpHub and Copilot Command Bar for iOS. '

# This description is used to generate tags and improve search results.
  s.description      = <<-DESC
  TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/tryfoobar/CommandBarIOS'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'CommandBar Engineering' => 'eng@commandbar.com' }
  s.source           = { :git => 'https://github.com/tryfoobar/CommandBarIOS.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'

  s.source_files = 'Sources/CommandBarIOS/**/*.swift'
  s.swift_versions = '5.0'
end
