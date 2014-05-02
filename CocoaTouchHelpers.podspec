Pod::Spec.new do |s|

  s.name         = "CocoaTouchHelpers"
  s.version      = "1.1.0"
  s.summary      = "Helper classes and categories for Cocoa Touch."
  s.homepage     = "https://github.com/maximkhatskevich/CocoaTouchHelpers"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "Maxim Khatskevich" => "maxim.khatskevich@gmail.com" }
  s.platform     = :ios, "6.0"

  s.source       = { :git => "https://github.com/maximkhatskevich/CocoaTouchHelpers.git", :tag => "1.1.0" }

  s.source_files  = "Src/**/*.{h,m}"
  s.requires_arc = true

end