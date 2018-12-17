
Pod::Spec.new do |s|
  s.name         = "RNGizwitsRnSdk"
  s.version      = "1.0.0"
  s.summary      = "RNGizwitsRnSdk"
  s.description  = <<-DESC
                  RNGizwitsRnSdk
                   DESC
  s.homepage     = ""
  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "author" => "author@domain.cn" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/author/RNGizwitsRnSdk.git", :tag => "master" }
  s.source_files  = "RNGizwitsRnSdk/**/*.{h,m}"
  s.requires_arc = true


  s.dependency "React"
  #s.dependency "others"

end

  