# UnlockGateway [![Code Climate](https://codeclimate.com/github/danielweinmann/unlock_gateway.png)](https://codeclimate.com/github/danielweinmann/unlock_gateway)

Abstract gateway for [Unlock](http://github.com/danielweinmann/unlock)'s payment gateway integrations

## Installation

Add this line to your gateway's .gemspec file:

``` ruby
s.add_dependency "unlock_gateway"
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

To let Unlock know what are the settings for this gateway, you should implement a method called _available_settings_ in your UnlockMyGatewayName::Models::Gateway that returns an array of UnlockGateway::Setting. Here is an example:

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

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


This project rocks and uses MIT-LICENSE.
