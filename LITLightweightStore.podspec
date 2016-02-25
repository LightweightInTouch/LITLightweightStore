#
# Be sure to run `pod lib lint LITLightweightStore.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "LITLightweightStore"
  s.version          = "0.1.0"
  s.summary          = "Lightweight key-value store which gives easy data access in memory, defaults and keychain domains."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
                     If you don't know how to store settings of your app, you can use this lightstore for this task.
                     Choose correct policy and store items without pain.
                     Also, you can switch policy very easy.
                     DESC

  s.homepage     = "https://github.com/LightweightInTouch/" + s.name

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author       = { "Dmitry Lobanov" => "gaussblurinc@gmail.com" }

  s.platform     = :ios

  s.ios.deployment_target = "7.0"

  s.source       = {
    :git => "https://github.com/LightweightInTouch/" + s.name + ".git",
    :submodules => false,
    :tag => s.version.to_s
  }

  s.source_files  = "Pod/**/*.{h,m}"
  s.exclude_files = "Example"
  s.frameworks = "Foundation", "SystemConfiguration", "Security"

  s.requires_arc = true
  s.dependency 'UICKeyChainStore'
  #s.resource_bundles = {
  #  'LITLightweightStore' => ['Pod/Assets/*.png']
  #}

end
