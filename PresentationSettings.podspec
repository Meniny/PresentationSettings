Pod::Spec.new do |s|
  s.name             = 'PresentationSettings'
  s.version          = "1.1.2"
  s.summary          = "Configuration for UIViewController presentation."
  s.homepage         = "https://github.com/Meniny/SuperAlertController"
  s.license          = { :type => "MIT", :file => "LICENSE.md" }
  s.author           = 'Elias Abel'
  s.source           = { :git => "https://github.com/Meniny/PresentationSettings.git", :tag => s.version.to_s }
  s.swift_version    = "4.0"
  s.social_media_url = 'https://meniny.cn/'
  s.source_files     = "PresentationSettings/**/*.{swift}"
  s.resources        = "PresentationSettings/**/*.{xib}"
  s.requires_arc     = true
  s.ios.deployment_target = "8.0"
  s.description      = "The configuration for UIViewController presentation."
  s.module_name      = 'PresentationSettings'
end
