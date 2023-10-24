Pod::Spec.new do |s|
  s.name             = 'CommandBarIOS'
  s.version          = '0.1.0'
  s.summary          = 'A short description of CommandBarIOS.'
  s.homepage         = 'https://github.com/tryfoobar/CommandBarIOS'
  s.license          = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author           = { 'CommandBar Engineering' => 'eng@commandbar.com' }
  s.source           = { :git => 'https://github.com/quickbirdeng/CommandBarIOS.git', :tag => s.version.to_s }
  s.ios.deployment_target = '12.0'
  s.swift_version = '5.0'
  s.source_files = 'Sources/CommandBarIOS/**/*'
end