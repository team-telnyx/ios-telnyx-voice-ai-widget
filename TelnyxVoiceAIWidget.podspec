Pod::Spec.new do |spec|
  spec.name         = "TelnyxVoiceAIWidget"
  spec.version      = "1.0.0"
  spec.summary      = "Telnyx Voice AI Widget SDK for iOS"
  spec.description  = <<-DESC
                      A comprehensive iOS SDK for integrating Telnyx Voice AI capabilities 
                      into your applications. Provides easy-to-use voice AI functionalities 
                      with seamless integration.
                      DESC

  spec.homepage     = "https://github.com/team-telnyx/ios-telnyx-voice-ai-widget"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author = { "Telnyx LLC" => "mobile.app.eng.chapter@telnyx.com" }

  spec.platform     = :ios, "13.0"
  spec.swift_version = "5.9"

  spec.source       = { :git => "https://github.com/team-telnyx/ios-telnyx-voice-ai-widget.git", :tag => "#{spec.version}" }

  spec.source_files = "TelnyxVoiceAIWidget/TelnyxVoiceAIWidget/**/*.swift"
  spec.resource_bundles = { "TelnyxVoiceAIWidget" => ["TelnyxVoiceAIWidget/TelnyxVoiceAIWidget/PrivacyInfo.xcprivacy"] }

  spec.frameworks = "Foundation", "UIKit", "AVFoundation"
  spec.requires_arc = true

  spec.dependency "TelnyxRTC", "2.4.0"
end
