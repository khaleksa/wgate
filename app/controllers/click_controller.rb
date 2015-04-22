class ClickController < ApplicationController
  skip_before_action :verify_authenticity_token
  ACTIONS = {
      prepare: 0,
      complete: 1
  }

  def sync
    binding.pry
    if request.method == "POST"
      action = request.request_parameters['action']
    else
      action = request.query_parameters['action']
    end
    binding.pry
    # if params[:action] == ACTIONS[:prepare]
    #   prepare
    # elsif params[:action] == ACTIONS[:prepare]
    #   complete
    # else

    # end
  end

  private
  def prepare
  end

  def complete

  end
end
