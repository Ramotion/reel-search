Pod::Spec.new do |s|

  s.name         = "RAMReel"
  s.version      = "2.1.0"
  s.summary      = "Live search control with reel of suggestions"
  s.screenshots  = "https://raw.githubusercontent.com/Ramotion/reel-search/master/reel-search.gif"

  s.homepage     = "https://github.com/Ramotion/reel-search"

  s.license      = "MIT"

  s.author       = { "Mikhail Stepkin, Ramotion Inc." => "mikhail.s@ramotion.com" }
  s.social_media_url = "https://twitter.com/Ramotion"

  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/Ramotion/reel-search.git", :tag => "#{s.version}" }

  s.source_files = "RAMReel/Framework", "RAMReel/Framework/**/*.{h,m,swift}"

  s.resources    = "RAMReel/Roboto/*.*"

end
