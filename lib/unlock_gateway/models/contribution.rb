module UnlockGateway
  module Models

    # This module will be included in Unlock's Contribution model. All methods will run in the context of an instance of Contribution model.
    module Contribution

      # This method should implement a way to check the state of the subscription with the gateway and update the contribution's state according to it's real state within the gateway.
      def update_state_from_gateway!
      end

    end

  end
end
