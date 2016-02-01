Pod::Spec.new do |s|

  s.name              = "RAMReel"
  s.version           = "1.0.1"
  s.summary           = "Live search control with reel of suggestions"

  s.homepage          = "https://github.com/Ramotion/reel-search"
  s.documentation_url = "https://rawgit.com/Ramotion/reel-search/master/docs/index.html"

  s.license           = "MIT"

  s.author            = { "Mikhail Stepkin, Ramotion Inc." => "mikhail.s@ramotion.com" }

  s.platform          = :ios, "8.0"

  s.source            = { :git => "https://github.com/Ramotion/reel-search.git", :tag => "1.0.1" }

  s.source_files      = "RAMReel/Framework", "RAMReel/Framework/**/*.{h,m,swift}"

  s.resources         = "RAMReel/Roboto/*.*"

  s.requires_arc      = true

end
