module UnlockGateway

  # This module will be extended (ClassMethods) and included by is_unlock_gateway on controllers
  module Controller

    module ClassMethods

      # This will be executed first, to set the controller up. Then the instance methods will be included
      def self.extended(base)
        base.class_eval do

          inherit_resources

          actions :create, :edit
          respond_to :html

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
        format.html { transition_state(:active) }
      end
    end
    
    # This action will be used when the user requests to suspend a contribution
    def suspend
      respond_to do |format|
        format.html { transition_state(:suspended) }
      end
    end

    private

    # Creates the contribution, sets session[:gateway_id], returns true if successful and renders new action if not
    def create_contribution

      @initiative = Initiative.find(contribution_params[:initiative_id])
      @gateways = @initiative.gateways.without_state(:draft).order(:ordering)
      @contribution = @initiative.contributions.new(contribution_params)
      @contribution.gateway_state = @contribution.gateway.state
      current_user.update module_name: @contribution.gateway.module_name
      authorize @contribution

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
      @initiative = resource.initiative
      @user = resource.user
      state = state.to_sym
      transition = resource.transition_by_state(state)
      initial_state = resource.state_name
      if resource.send("can_#{transition}?")
        begin
          if resource.state_on_gateway != state
            if resource.update_state_on_gateway!(state)
              resource.send("#{transition}!")
            else
              flash[:failure] = "Não foi possível alterar o status de seu apoio."
            end
          else
            resource.send("#{transition}!")
          end
        rescue
          flash[:failure] = "Ooops, ocorreu um erro ao alterar o status de seu apoio."
        end
      else
        flash[:failure] = "Não foi permitido alterar o status deste apoio."
      end
      if flash[:failure].present?
        render 'initiatives/contributions/show'
      else
        if initial_state == :pending
          flash[:success] = "Apoio realizado com sucesso!"
        else
          flash[:success] = "Status do apoio alterado com sucesso!"
        end
        redirect_to initiative_contribution_path(resource.initiative.id, resource)
      end
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
