#
#  Be sure to run `pod spec lint MTLog.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.name         = "MTLog"
  s.version      = "0.6.1"
  s.summary      = "NSLog replacement for coders!"

  s.description  = "Logging is essential part of debugging and I was often irritated that NSLog is not as flexible as I'd like it to be. Therefore I came around writing MTLog - the flexible logging tool that I need."



  s.homepage     = "https://github.com/icanzilb/MTLog"

  s.license      = "MIT (example)"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }

  s.author             = { "Marin Todorov" => "touch-code-magazine@underplot.com" }

  s.source       = { :git => "https://github.com/icanzilb/MTLog.git", :tag => "0.6.1" }

  s.source_files  = "MTLog", "MTLog/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"

  s.requires_arc = true

end
