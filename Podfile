# Uncomment the next line to define a global platform for your project
 platform :ios, '13.0'

target 'CleverTapManualIntegration' do
  # Comment the next line if you don't want to use dynamic frameworks
  #use_frameworks!
  use_modular_headers!

  # Pods for CleverTapManualIntegration
    pod 'CleverTap-iOS-SDK'
    pod 'FirebaseAnalytics'
    pod 'FirebaseMessaging'
    
    target 'NotificationService' do
      pod 'CTNotificationService'
    end
    
    target 'NotificationContent' do
      pod 'CTNotificationContent'
    end


  target 'CleverTapManualIntegrationTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'CleverTapManualIntegrationUITests' do
    # Pods for testing
  end

end
