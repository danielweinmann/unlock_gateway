module UnlockGateway

  # This module will be extended (ClassMethods) and included by is_unlock_gateway on controllers
  module Controller

    module ClassMethods

      # This will be executed first, to set the controller up. Then the instance methods will be included
      def self.extended(base)
        base.class_eval do

          before_action :set_contribution, only: %i[edit activate suspend]

          respond_to :html

          after_action :verify_authorized
          after_action :verify_policy_scoped, only: %i[]
          before_action :authenticate_user!, only: %i[edit]

        end
      end

    end

    # A second step or final checkout should use this action
    def edit
      authorize @contribution
    end

    # This action will be used when the user requests to activate/reactivate a contribution
    def activate
      transition_state(:active)
    end
    
    # This action will be used when the user requests to suspend a contribution
    def suspend
      transition_state(:suspended)
    end

    private

    # Sets @contribution
    def set_contribution
      @contribution = Contribution.find(params[:id])
    end

    # Creates the contribution, sets session[:gateway_id], returns true if successful and renders new action if not
    def create_contribution

      @initiative = Initiative.find(contribution_params[:initiative_id])
      @gateways = @initiative.gateways.without_state(:draft).ordered
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

    # This method authorizes @contribution, checks if the contribution can be transitioned to the desired state, calls Contribution#update_state_on_gateway!, transition the contribution's state, and return the proper JSON for Unlock's AJAX calls
    def transition_state(state)
      authorize @contribution
      @initiative = @contribution.initiative
      @user = @contribution.user
      state = state.to_sym
      transition = @contribution.transition_by_state(state)
      initial_state = @contribution.state_name
      resource_name = @contribution.class.model_name.human
      if @contribution.send("can_#{transition}?")
        begin
          if @contribution.state_on_gateway != state
            if @contribution.update_state_on_gateway!(state)
              @contribution.send("#{transition}!")
            else
              flash[:alert] = t('flash.actions.update.alert', resource_name: resource_name)
            end
          else
            @contribution.send("#{transition}!")
          end
        rescue
          flash[:alert] = t('flash.actions.update.alert', resource_name: resource_name)
        end
      else
        flash[:alert] = t('flash.actions.update.alert', resource_name: resource_name)
      end
      if flash[:alert].present?
        render 'initiatives/contributions/show'
      else
        if initial_state == :pending
          flash[:notice] = t('flash.actions.create.notice', resource_name: resource_name)
        else
          flash[:notice] = t('flash.actions.update.notice', resource_name: resource_name)
        end
        redirect_to initiative_contribution_path(@contribution.initiative.id, @contribution)
      end
    end

    # Strong parameters for Contribution    
    def contribution_params
      params.require(:contribution).permit(*policy(@contribution || Contribution.new).permitted_attributes)
    end

  end
end
