module UnlockGateway

  # This module will be extended (ClassMethods) and included by is_unlock_gateway on controllers
  module Controller

    module ClassMethods

      # This will be executed first, to set the controller up. Then the instance methods will be included
      def self.extended(base)
        base.class_eval do

          inherit_resources

          actions :create, :edit
          respond_to :html, except: [:activate, :suspend]
          respond_to :json, only: [:activate, :suspend]

          after_action :verify_authorized
          after_action :verify_policy_scoped, only: %i[]
          before_action :authenticate_user!, only: %i[edit]

        end
      end

    end

    # A second step or final checkout should use this action
    def edit
      edit! { authorize resource }
    end

    # This action will be used when the user requests to activate/reactivate a contribution
    def activate
      respond_to do |format|
        format.json { transition_state(:active) }
      end
    end
    
    # This action will be used when the user requests to suspend a contribution
    def suspend
      respond_to do |format|
        format.json { transition_state(:suspended) }
      end
    end

    private

    # Creates the contribution, sets session[:gateway_id], returns true if successful and renders new action if not
    def create_contribution

      @initiative = Initiative.find(contribution_params[:initiative_id])
      @gateways = @initiative.gateways.without_state(:draft).order(:ordering)
      @contribution = @initiative.contributions.new(contribution_params)
      @contribution.gateway_state = @contribution.gateway.state
      authorize @contribution
      session[:gateway_id] = @contribution.gateway.id

      if @contribution.save
        true
      else
        render '/initiatives/contributions/new'
        false
      end

    end

    # This method authorizes the resource, checks if the contribution can be transitioned to the desired state, calls Contribution#update_state_on_gateway!, transition the contribution's state, and return the proper JSON for Unlock's AJAX calls
    def transition_state(state)
      authorize resource
      errors = []
      state = state.to_sym
      transition = resource.transition_by_state(state)
      if resource.send("can_#{transition}?")
        begin
          if resource.state_on_gateway != state
            if resource.update_state_on_gateway!(state)
              resource.send("#{transition}!")
            end
          else
            resource.send("#{transition}!")
          end
        rescue
          errors << "Não foi possível alterar o status de seu apoio."
        end
      else
        errors << "Não foi permitido alterar o status deste apoio."
      end
      render(json: {success: (errors.size == 0), errors: errors}, status: ((errors.size == 0) ? 200 : 422))
    end

    # Strong parameters for Contribution. This duplication is due to a inherited_resources problem that requires both
    def permitted_params
      params.permit(contribution: policy(@contribution || Contribution.new).permitted_attributes)
    end

    # Strong parameters for Contribution    
    def contribution_params
      params.require(:contribution).permit(*policy(@contribution || Contribution.new).permitted_attributes)
    end

  end
end
