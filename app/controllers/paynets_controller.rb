class PaynetsController < ApplicationController
  skip_before_action :verify_authenticity_token
  # force_ssl

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
      response = XML_HEADER + send(action_name)
      render text: response, content_type: 'text/xml'
    else
      head :not_found
    end
  end

  def perform_transaction
    params = Hash.from_xml(request.body.read)
    return Paynet::TransactionBuilder.new(params).build_response
  end

  def check_transaction
    params = Hash.from_xml(request.body.read)
    return Paynet::TransactionCheck.new(params).build_response
  end

  def cancel_transaction
    params = Hash.from_xml(request.body.read)
    return Paynet::TransactionCancel.new(params).build_response
  end

  def get_statement
    params = Hash.from_xml(request.body.read)
    return Paynet::TransactionStatements.new(params).build_response
  end
  
  private
  def check_ip
    ip_list = PAYNET_CONFIG[:ip_list]
    raise 'Not allowed' until ip_list.include? request.remote_ip
  end
end
