#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint sim_card_code.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'sim_card_code'
  s.version          = '0.2.0'
  s.summary          = 'A Flutter plugin for accessing SIM card and device cellular information.'
  s.description      = <<-DESC
A Flutter plugin for accessing SIM card details, phone number country code,
network info, eSIM status and multi-SIM (subscription) information.
                       DESC
  s.homepage         = 'https://github.com/mustafa-707/sim_card_code'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'mustafa-707' => 'https://github.com/mustafa-707' }
  s.source           = { :path => '.' }
  s.source_files     = 'sim_card_code/Sources/sim_card_code/**/*.swift'
  s.resource_bundles = { 'sim_card_code_privacy' => ['sim_card_code/Sources/sim_card_code/PrivacyInfo.xcprivacy'] }
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'
  s.frameworks = 'CoreTelephony'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
