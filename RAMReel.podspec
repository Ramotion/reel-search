Pod::Spec.new do |s|

  s.name         = "RAMReel"
  s.version      = "0.9.0"
  s.summary      = "Live search control with reel of suggestions"

  s.description  = <<-DESC
                   A longer description of RAMReel in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "https://github.com/Ramotion/reel-search"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

  s.license      = "MIT"

  s.author       = { "Mikhail Stepkin" => "mikhail.s@ramotion.com" }

  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/Ramotion/reel-search.git", :tag => "0.9.0" }

  s.source_files = "RAMReel/Framework", "RAMReel/Framework/**/*.{h,m}"

  s.resources    = "RAMReel/Roboto/*.*"

  s.requires_arc = true

end
