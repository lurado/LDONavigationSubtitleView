#
# Be sure to run `pod lib lint LDONavigationSubtitleView.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "LDONavigationSubtitleView"
  s.version          = "1.2"
  s.summary          = "UINavigationItem title view with subtitle and nice animations."
  s.description      = <<-DESC
                       LDONavigationSubtitleView is a drop in replacement for the default
                       navigation item title that is displayed in a UINavigationBar. If you
                       only set a title, it looks just like the default. However, it supports
                       an optional subtitle to be displayed unterneath the title.

                       * Changes to title or subtitle can be animated (optional)
                       * Supports Interface Builder customization
                       * Looks good in Landscape & Portrait
                       * Universal for iPhone and iPad
                       DESC
  s.homepage         = "https://github.com/lurado/LDONavigationSubtitleView"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Julian Raschke und Sebastian Ludwig GbR" => "info@lurado.com" }
  s.source           = { :git => "https://github.com/lurado/LDONavigationSubtitleView.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
