# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'cyclid-gh-comment-plugin'
  s.version     = '0.1.0'
  s.licenses    = ['Apache-2.0']
  s.summary     = 'Cyclid Github Comment plugin'
  s.description = 'Add comments to Github issues & pull requests'
  s.authors     = ['Kristian Van Der Vliet']
  s.homepage    = 'https://cyclid.io'
  s.email       = 'contact@cyclid.io'
  s.files       = Dir.glob('lib/**/*')

  s.add_runtime_dependency('cyclid', '~> 0.3')
  s.add_runtime_dependency('octokit', '~> 4.3')
end
