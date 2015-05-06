class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def parse_date(date)
    Time.zone.parse(date.to_s)
  end

  private
  def render_status(status)
    render :nothing => true, :status => status
  end
end
