require 'unlock_gateway/setting'
require "unlock_gateway/controller"
require "unlock_gateway/models/gateway"
require "unlock_gateway/models/contribution"

module UnlockGateway
end

class ActionController::Base
  # Extends and includes UnlockGateway::Controller class and instance methods, preparing a controller to be an unlock gateway controller
  def self.is_unlock_gateway
    extend UnlockGateway::Controller::ClassMethods
    include UnlockGateway::Controller
  end
end
