$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "unlock_gateway/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "unlock_gateway"
  s.version     = UnlockGateway::VERSION
  s.authors     = ["Daniel Weinmann"]
  s.email       = ["danielweinmann@gmail.com"]
  s.homepage    = "https://github.com/danielweinmann/unlock_gateway"
  s.summary     = "Base gateway for Unlock's payment gateway integrations"
  s.description = "Base gateway for Unlock's payment gateway integrations"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.1.6"
end
