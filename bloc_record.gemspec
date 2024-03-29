Gem::Specification.new do |s|
    s.name          = 'bloc_record'
    s.version       = '0.0.0'
    s.date          = '2019-07-10'
    s.summary       = 'BlocRecord ORM'
    s.description   = 'An ActiveRecord-esque ORM adaptor'
    s.authors       = ['Andrew Delapaz']
    s.email         = 'thedelapaz@gmail.com'
    s.files         = Dir['lib/**/*.rb']
    s.require_paths = ["lib"]
    s.homepage      =
      'http://rubygems.org/gems/bloc_record'
    s.license       = 'MIT'
    s.add_runtime_dependency 'sqlite3', '~> 1.3'
  end