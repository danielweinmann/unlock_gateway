module UnlockGateway
  module Models
    module Gateway

      def name
        self.module_name
      end

      def description
      end

      def image
      end

      def path
      end

      def has_sandbox?
        true
      end

      def available_settings
        []
      end

    end
  end
end
