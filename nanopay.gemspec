require 'English'

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require_relative 'lib/nanopay/version'

Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new('>= 0') if s.respond_to? :required_rubygems_version=
  s.rubygems_version = '2.2'
  s.required_ruby_version = '>=2.5'
  s.name = 'nanopay'
  s.version = NanoPay::VERSION
  s.license = 'MIT'
  s.summary = 'A fast cryptocurrency for micro payments'
  s.description = 'Experiemental Non-Blockhain Node'
  s.authors = ['Yegor Bugayenko']
  s.email = 'yegor256@gmail.com'
  s.homepage = 'http://github.com/NanoOfficial/nanopay'
  s.post_install_message = "Thanks for installing NanoPay #{NanoPay::VERSION}!"
  s.files = `git ls-files`.split($RS)
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files = s.files.grep(%r{^(test|features)/})
  s.rdoc_options = ['--charset=UTF-8']
  s.extra_rdoc_files = ['README.md', 'LICENSE.txt']
  s.add_runtime_dependency 'backtrace', '>=0.3'
  s.add_runtime_dependency 'concurrent-ruby', '~>1.1'
  s.add_runtime_dependency 'diffy', '~>3.3'
  s.add_runtime_dependency 'futex', '>=0.8.5'
  s.add_runtime_dependency 'get_process_mem', '~>0.2'
  s.add_runtime_dependency 'haml', '~>5.0'
  s.add_runtime_dependency 'json', '~>2.2'
  s.add_runtime_dependency 'memory_profiler', '~>0.9'
  s.add_runtime_dependency 'mimic', '~>0.4'
  s.add_runtime_dependency 'openssl', '~>2.1'
  s.add_runtime_dependency 'rainbow', '~>3.0'
  s.add_runtime_dependency 'semantic', '~>1.6'
  s.add_runtime_dependency 'sinatra', '~>2.0'
  s.add_runtime_dependency 'slop', '~>4.6'
  s.add_runtime_dependency 'sys-proctable', '~>1.2'
  s.add_runtime_dependency 'thin', '~>1.7'
  s.add_runtime_dependency 'threads', '>=0.3'
  s.add_runtime_dependency 'total', '>=0.3'
  s.add_runtime_dependency 'typhoeus', '~>1.3'
  s.add_runtime_dependency 'usagewatch_ext', '~>0.2'
  s.add_runtime_dependency 'zache', '>=0.12'
end