class PaynetsController < ApplicationController
  skip_before_action :verify_authenticity_token
  force_ssl

  before_filter :check_ip

  XML_HEADER = "<?xml version='1.0' encoding='UTF-8'?>\n"

  def wsdl
    wsdl_path = File.join Rails.public_path, 'ProviderWebService.wsdl'
    wsdl_file = File.read wsdl_path
    render text: wsdl_file.html_safe, content_type: 'text/xml'
  end

  def action
    action_name = request.headers['SOAPAction'].gsub('urn:', '').gsub('"', '').underscore
    if self.respond_to?(action_name, true)
      params = Hash.from_xml(request.body.read)
      response = XML_HEADER + send(action_name, params)
      render text: response, content_type: 'text/xml'
    else
      head :not_found
    end
    log(action_name, params)
  end

  private
  def perform_transaction(params)
    return Paynet::PerformTransaction.new(params).build_response
  end

  def check_transaction(params)
    return Paynet::CheckTransaction.new(params).build_response
  end

  def cancel_transaction(params)
    return Paynet::CancelTransaction.new(params).build_response
  end

  def get_statement(params)
    return Paynet::GetStatement.new(params).build_response
  end
  
  def check_ip
    ip_list = PAYNET_CONFIG[:ip_list]
    raise 'Not allowed' until ip_list.include? request.remote_ip
  end

  def log(action_name, request)
    data = "#{Time.zone.now} - action:#{action_name.to_s} request:#{request.to_s}"
    ::Logger.new("#{Rails.root}/log/paynet_controller_#{Time.zone.now.month}_#{Time.zone.now.year}.log").info(data)
  end
end
