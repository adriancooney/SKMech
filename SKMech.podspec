#
# Be sure to run `pod lib lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = "SKMech"
  s.version          = "0.1.0"
  s.summary          = "SpriteKit tools."
  # s.homepage         = "http://EXAMPLE/NAME"
  # s.screenshots      = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Adrian Cooney" => "cooney.adrian@gmail.com" }
  # s.source           = { :git => "http://EXAMPLE/NAME.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/adrian_cooney'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Classes'
end
