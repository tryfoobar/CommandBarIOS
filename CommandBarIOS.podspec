Pod::Spec.new do |s|
  s.name             = 'CommandBarIOS'
  s.version          = '0.3.0'
  s.summary          = 'CommandBarIOS: Open the HelpHub/Copilot from your iOS app.'
  s.homepage         = 'https://github.com/tryfoobar/CommandBarIOS'
  s.license          = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author           = { 'CommandBar Engineering' => 'eng@commandbar.com' }
  s.source           = { :git => 'https://github.com/tryfoobar/CommandBarIOS.git', :tag => s.version.to_s }
  s.ios.deployment_target = '12.0'
  s.swift_version = '5.0'
  s.source_files = 'Sources/CommandBarIOS/**/*'
end