Pod::Spec.new do |s|
  s.name     = 'YRDropdownView'
  s.version  = '0.2.1'
  s.platform = :ios
  s.license  = 'MIT'
  s.summary  = 'YRDropdownView is a view library for displaying stylish alerts, warnings, and errors.'
  s.homepage = 'http://buildinternet.com/2012/02/yrdropdownview-a-polite-uialertview-alternative-for-ios/'
  s.author   = { 'Eli Perkins' => 'eli@onemightyroar.com' }
  s.source   = { :git => 'https://github.com/iOctocat/YRDropdownView.git', :tag => 'v0.2.1' }
  s.source_files = 'YRDropdownView/*.{h,m}'
  s.resources    = 'YRDropdownView/*.png'
  s.requires_arc = true
end
