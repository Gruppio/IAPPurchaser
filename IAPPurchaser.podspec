Pod::Spec.new do |s|
  s.name         = "IAPPurchaser"
  s.version      = "1.0.3"
  s.summary      = "Perform and track In App Purchases"
  s.swift_version = "5.1"
  s.description  = <<-DESC
    An easy way to perform and keep track of In App Purchases
  DESC
  s.homepage     = "https://github.com/Gruppio/IAPPurchaser.git"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Michele Gruppioni" => "gruppiofigo@hotmail.it" }
  s.social_media_url   = ""
  s.ios.deployment_target = "13.0"
  s.tvos.deployment_target = "13.0"
  s.macos.deployment_target = "10.15"
  s.source       = { :git => "https://github.com/Gruppio/IAPPurchaser.git", :tag => s.version.to_s }
  s.source_files  = "Sources/IAPPurchaser/**/*"
  #s.tvos.exclude_files = "Sources/ReceiptReader.swift"
  s.frameworks  = "Foundation"
  s.dependency "TPInAppReceipt"
  #s.ios.dependency "TPInAppReceipt"
  #s.tvos.dependency "TPInAppReceipt"
end
