Pod::Spec.new do |s|
  s.name   = 'RealmMapper'
  s.version  = '1.0.1'
  s.license  = 'MIT'
  s.summary  = 'RealmMapper'
  s.homepage = 'https://github.com/zendobk/RealmMapper'
  s.authors  = { 'Dao Nguyen' => 'zendobk' }
  s.source   = { :git => 'https://github.com/zendobk/RealmMapper.git', :tag => s.version}
  s.requires_arc = true
  s.ios.deployment_target = '8.0'
	s.ios.frameworks = 'Foundation', 'UIKit'
  s.dependency 'RealmSwift', '~> 0.98'
  s.dependency 'ObjectMapper', '~> 1.1'
  s.source_files = 'RealmMapper/*.swift'
end