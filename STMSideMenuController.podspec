#
# Be sure to run `pod lib lint STMSideMenuController.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "STMSideMenuController"
  s.version          = "1.2.1"
  s.summary          = "A Google-like side-menu/drawer for iOS written in Objective-C"
  s.description      = <<-DESC
                       A Google-like side-menu/drawer (both left and/or right) for iOS written in Objective-C with custom transition for central section
                       DESC
  s.homepage         = "https://github.com/stefanomondino/STMSideMenuController"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Stefano Mondino" => "stefano.mondino.dev@gmail.com" }
  s.source           = { :git => "https://github.com/stefanomondino/STMSideMenuController.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/puntoste'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'


end
