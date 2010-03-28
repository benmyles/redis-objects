spec = Gem::Specification.new do |s|
  s.name = 'benmyles-redis-objects'
  s.version = '0.2.3'
  s.summary = "Maps Redis types to Ruby objects"
  s.description = %{Map Redis types directly to Ruby objects. Works with any class or ORM.}
  s.files = Dir['lib/**/*.rb'] + Dir['spec/**/*.rb']
  s.require_path = 'lib'
  #s.autorequire = 'redis/objects'
  s.has_rdoc = true
  s.rubyforge_project = 'benmyles-redis-objects'
  s.extra_rdoc_files = Dir['[A-Z]*']
  s.rdoc_options << '--title' <<  'Redis::Objects -- Use Redis types as Ruby objects'
  s.author = "Ben Myles"
  s.email = "ben.myles@gmail.com"
  s.homepage = "http://github.com/benmyles/redis-objects"
  s.requirements << 'redis, v0.1 or greater'
  s.add_dependency('redis', '>= 0.1')
end

