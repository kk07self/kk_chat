Pod::Spec.new do |s|

s.name         = 'kk_chat'
s.version      = '0.0.1'
s.summary      = 'a component of refresh on iOS'
s.homepage     = 'https://github.com/CoderJFCK/kk_chat'
s.description  = <<-DESC
It is a component for ios chat toolbar, written by Swift.
DESC
s.license      = 'MIT'
s.authors      = {'Kirk' => 'kk.07.self@gmail.com'}
s.platform     = :ios, '8.0'
s.source       = {:git => 'https://github.com/CoderJFCK/kk_chat.git', :tag => s.version}
s.source_files = 'kk_chat/kk_chat/*'
s.requires_arc = true

end
