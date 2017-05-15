source 'https://github.com/CocoaPods/Specs.git'
inhibit_all_warnings!
use_frameworks!
platform :ios, '8.0'

def shared_pods
    pod 'RealmSwift', '~> 2.4'
    pod 'ObjectMapper', '~> 2.2'
end

target 'RealmMapper' do  
    shared_pods
    pod 'SwiftLint', '~> 0.17.0'
    target 'Tests' do
        inherit! :search_paths
        shared_pods
    end
end
