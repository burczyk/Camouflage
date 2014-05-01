Pod::Spec.new do |s|
  s.name         = "Camouflage"
  s.version      = "1.0.0"
  s.summary      = "Read and write NSData to iOS Camera Roll as .bmp file and share it between apps!"

  s.description  = <<-DESC
                   A longer description of Camouflage in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "https://github.com/burczyk/Camouflage"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Kamil Burczyk" => "kamil.burczyk@gmail.com" }
  s.social_media_url   = "http://twitter.com/KamilBurczyk"
  s.platform     = :ios, "6.0"
  s.source       = { :git => "https://github.com/burczyk/Camouflage.git", :tag => "1.0.0" }
  s.source_files  = "Camouflage", "Camouflage/**/*.{h,m,c}"
  s.public_header_files = "Camouflage/**/*.h"
  s.framework  = "AssetsLibrary"
  s.requires_arc = true
end
