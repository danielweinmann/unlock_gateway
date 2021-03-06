# UnlockGateway [![Code Climate](https://codeclimate.com/github/danielweinmann/unlock_gateway.png)](https://codeclimate.com/github/danielweinmann/unlock_gateway)

Base gateway for [Unlock](http://github.com/danielweinmann/unlock)'s payment gateway integrations

## Installation

Create a Rails full Engine with:

``` terminal
rails plugin new unlock_my_gateway_name --full
```

Add this line to your gateway's .gemspec file:

``` ruby
s.add_dependency "unlock_gateway"
```

Require `unlock_gateway` before anything else:

``` ruby
# On lib/unlock_my_gateway_name.rb
require "unlock_gateway"
```

## Usage

### Gateway module

Every gateway should implement a module UnlockMyGatewayName::Models::Gateway that follows the pattern described [here](https://github.com/danielweinmann/unlock_gateway/blob/master/lib/unlock_gateway/models/gateway.rb). You should add the following to this module:

``` ruby
include UnlockGateway::Models::Gateway
```

### Contribution module

Every gateway should implement a module UnlockMyGatewayName::Models::Contribution that follows the pattern described [here](https://github.com/danielweinmann/unlock_gateway/blob/master/lib/unlock_gateway/models/contribution.rb). You should add the following to this module:

``` ruby
include UnlockGateway::Models::Contribution
```

### Setting class

To let Unlock know what are the settings for this gateway, you should implement a method called _available_settings_ in your UnlockMyGatewayName::Models::Gateway that returns an array of [UnlockGateway::Setting](https://github.com/danielweinmann/unlock_gateway/blob/master/lib/unlock_gateway/setting.rb). Here is an example:

``` ruby
# In your lib/unlock_my_gateway_name/models/gateway.rb
module UnlockMyGatewayName
  module Models
    module Gateway

      include UnlockGateway::Models::Gateway

      def available_settings
        settings = []
        settings << UnlockGateway::Setting.new(:token, "Your API token", "Instructions")
        settings << UnlockGateway::Setting.new(:key, "Your API key", "Instructions")
      end

    end
  end
end
```

### Controller

You should define a ContributionsController in your gateway, such as

``` ruby
class UnlockMyGatewayName::ContributionsController < ::ApplicationController
  is_unlock_gateway
end
```

Calling `is_unlock_gateway` inside you controller will extend UnlockGateway::Controller::ClassMethods and include UnlockGateway::Controller, preparing your controller to be an unlock gateway controller. You can check out what is added to your controller [here](https://github.com/danielweinmann/unlock_gateway/blob/master/lib/unlock_gateway/controller.rb).

### Views

The only view you _need_ to create is a partial called `unlock_my_gateway_name/contributions/_form`, that will receive a local variable `gateway`. In this partial you can render the [sandbox_warning](https://github.com/danielweinmann/unlock/blob/master/app/views/initiatives/contributions/_sandbox_warning.html.slim) and [base_form](https://github.com/danielweinmann/unlock/blob/master/app/views/initiatives/contributions/_base_form.html.slim) partials to avoid duplicating code. Here is an example:

``` ruby
# In your views/unlock_my_gateway_name/contributions/_form.html.slim
= form_for @contribution, url: my_gateway_name_contributions_path, method: :post do |form|
  = render partial: 'initiatives/contributions/sandbox_warning', locals: { gateway: gateway }
  = render partial: 'initiatives/contributions/base_form', locals: { form: form, gateway: gateway }
  = form.submit "Proceed to checkout"
```

### Routes

You should add a `:my_gateway_name_contributions` resource in your `config/routes.rb` that uses `UnlockMyGatewayName::ContributionsController` and has the same path as you've defined in `UnlockMyGatewayName::Models::Gateway#path`. You should also always add member actions `activate` and `suspend`. Here is an example:

``` ruby
# In your config/routes.rb
Rails.application.routes.draw do

  resources :my_gateway_name_contributions, controller: 'unlock_my_gateway_name/contributions', only: [:create, :edit, :update], path: '/my_gateway_name' do
    member do
      put :activate
      put :suspend
    end
  end

end
```

### Registering the gateway with Unlock's Gateway model

You should add an initializer to register the gateway, otherwise it won't show as an option for Unlock's users.

``` ruby
# In your config/initializers/register.rb
UnlockGateway.register 'UnlockMyGatewayName'
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


This project rocks and uses MIT-LICENSE.
