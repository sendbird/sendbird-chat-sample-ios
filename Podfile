platform :ios, '13.0'

workspace 'Samples'
project 'CommonModule/CommonModule.xcodeproj'
project 'BasicGroupChannel/BasicGroupChannel.xcodeproj'
project 'BasicOpenChannel/BasicOpenChannel.xcodeproj'

def shared
  pod 'SendBirdSDK', '3.1.7'
  pod 'Kingfisher', '~>7.0.0'
end

target 'CommonModule' do
  project 'CommonModule/CommonModule.xcodeproj'
  shared
end

target 'BasicGroupChannel' do
  project 'BasicGroupChannel/BasicGroupChannel.xcodeproj'
  shared
end

target 'BasicOpenChannel' do
  project 'BasicOpenChannel/BasicOpenChannel.xcodeproj'
  shared
end
