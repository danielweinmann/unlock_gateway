module UnlockGateway
  module Models

    # Your module UnlockMyGatewayName::Models::Contribution, that should implement this interface, will be included in Unlock's Contribution model. All methods will run in the context of an instance of Contribution model.
    module Contribution

      # This method should return the unique identifier of the contribution on the gateway
      def gateway_identifier
      end

      # This method should return the actual state of a contribution on the gateway, with name according to Contribution's state machine, as a Symbol.
      def state_on_gateway
      end

      # This method should change the state of a contribution on the gateway, according to the new desired state.
      def update_state_on_gateway!(state)
      end

      # Updates the contribution's state according to it's actual state within the gateway, based on each gateway's implementation of state_on_gateway.
      def update_state_from_gateway!
        return unless gateway_state = self.state_on_gateway
        if self.state_name != gateway_state
          transition = self.transition_by_state(gateway_state)
          self.send("#{transition}!") if self.send("can_#{transition}?")
        end
      end

      # Helper method to find transition name by the desired new state name
      def transition_by_state(state)
        state = state.try(:to_sym)
        case state
          when :active
            :activate
          when :suspended
            :suspend
        end
      end

    end

  end
end
