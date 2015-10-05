#
# Be sure to run `pod lib lint SLNavigationSubtitleView.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "SLNavigationSubtitleView"
  s.version          = "1.1.2.1"
  s.summary          = "UINavigationItem title view with subtitle and nice animations."
  s.description      = <<-DESC
                       SLNavigationSubtitleView is a drop in replacement for the default
                       navigation item title that is displayed in a UINavigationBar. If you
                       only set a title, it looks just like the default. However, it supports
                       an optional subtitle to be displayed unterneath the title.

                       * Changes to title or subtitle can be animated (optional)
                       * Supports Interface Builder customization
                       * Looks good in Landscape & Portrait
                       * Universal for iPhone and iPad
                       DESC
  s.homepage         = "https://github.com/sebastianludwig/SLNavigationSubtitleView"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Sebastian Ludwig" => "sebastian@lurado.de" }
  s.source           = { :git => "https://github.com/sebastianludwig/SLNavigationSubtitleView.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.deprecated_in_favor_of = 'LDONavigationSubtitleView'

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'SLNavigationSubtitleView' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
