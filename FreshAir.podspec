Pod::Spec.new do |s|
  s.name             = "FreshAir"
  s.version          = "0.2"
  s.summary          = "An application update library."
  s.homepage         = "https://github.com/Raizlabs/FreshAir"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "Michael Gorbach" => "michael@mgorbach.name", "Brian King" => "brianaking@gmail.com", "Blake Skinner" => "bskinner@chaoticminds.org" }
  s.source           = { :git => "https://github.com/Raizlabs/FreshAir.git", :tag => s.version.to_s }
  s.social_media_url = "http://twitter.com/raizlabs"

  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.default_subspec = 'FreshAir'

  s.subspec "AppStoreCheck" do |ss|
    ss.source_files = 'FreshAir/RZFAppStoreUpdateCheck.{h,m}'
  end

  s.subspec "FreshAir" do |ss|
    ss.source_files = 'FreshAir/**/*.{h,m}'
  end

  s.resource_bundles = {
    'FreshAir' => ['FreshAir/FreshAir/UI/FreshAirUpdate.strings']
  }
end
