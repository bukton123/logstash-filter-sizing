Gem::Specification.new do |s|
  s.name = 'logstash-filter-sizing'
  s.version         = '1.1.0'
  s.licenses = ['Apache License (2.0)']
  s.summary = "This example filter replaces the contents of the message field with the specified value."
  s.description     = "This gem is a Logstash plugin required to be installed on top of the Logstash core pipeline using $LS_HOME/bin/logstash-plugin install gemname. This gem is not a stand-alone program"
  s.authors = ["BukTon"]
  s.email = 'info@bukton.xyz'
  s.homepage = "https://bukton.xyz"
  s.require_paths = ["lib"]

  # Files
  s.files = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE','NOTICE.TXT']
   # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "filter" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core-plugin-api", "~> 2.0"
  s.add_runtime_dependency "metriks"                          #(MIT license)
  s.add_runtime_dependency "thread_safe"

  s.add_development_dependency 'logstash-devutils'
  s.add_development_dependency 'insist'
end
