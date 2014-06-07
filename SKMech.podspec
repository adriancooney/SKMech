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
  s.license          = 'MIT'
  s.homepage         = "http://github.com/adriancooney/SKMech"
  s.author           = { "Adrian Cooney" => "cooney.adrian@gmail.com" }
  s.source           = { :git => "https://github.com/adriancooney/SKMech.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/adrian_cooney'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Classes'
  s.header_mappings_dir = 'Classes'
  
  s.subspec 'Library' do |ss|
    ss.source_files = 'Classes/Library'
    ss.subspec 'Trees' do |sss|
      sss.source_files = 'Classes/Library/Trees'
    end
  end
end
