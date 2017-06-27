Pod::Spec.new do |s|

s.name         = 'kk_chat'
s.version      = '1.0.5'
s.summary      = 'a component of refresh on iOS'
s.homepage     = 'https://github.com/CoderJFCK/kk_chat'
s.description  = <<-DESC
It is a component for ios chat toolbar, written by Swift.
DESC
s.license      = 'MIT'
s.authors      = {'Kirk' => 'kk.07.self@gmail.com'}
s.platform     = :ios, '8.0'
s.source       = {:git => 'https://github.com/CoderJFCK/kk_chat.git', :tag => s.version}
s.source_files = 'kk_chat/kk_chat/*.swift'
s.resource_bundles = {
    'images' => ['kk_chat/kk_chat/Resource/*.png'],
    'xibs' => ['kk_chat/kk_chat/*.xib'],
    'others' => ['kk_chat/kk_chat/Resource/*.plist']
}
s.requires_arc = true

end
