class Paynet::PaynetsController < ApplicationController
  skip_before_action :verify_authenticity_token
  force_ssl if: :ssl_configured?

  before_filter :check_ip

  XML_HEADER = "<?xml version='1.0' encoding='UTF-8'?>\n"

  def wsdl(provider_id)
    set_log_file unless @log_file
    logger = ::Logger.new(@log_file)
    logger.info("------------------------- wsdl from ip=#{request.remote_ip} ----------------------")

    wsdl_path = File.join Rails.public_path, 'ProviderWebService.wsdl'
    wsdl_file = File.read wsdl_path

    provider = Provider.find(provider_id)
    wsdl_file = wsdl_file.gsub('83.221.163.177', 'application') if Rails.env.test?
    wsdl_file = wsdl_file.gsub('*client*', provider.name.strip)

    render text: wsdl_file.html_safe, content_type: 'text/xml'
  end

  def action(provider_id)
    action_name = request.headers['SOAPAction'].gsub('urn:', '').gsub('"', '').underscore
    params = Hash.from_xml(request.body.read)
    log(action_name, provider_id, params)

    if self.respond_to?(action_name, true)
      response = XML_HEADER + send(action_name, params, provider_id)
      render text: response, content_type: 'text/xml'
    else
      head :not_found
    end
  end

  private
  def perform_transaction(params, provider_id)
    return Paynet::PerformTransaction.new(params, provider_id).build_response
  end

  def check_transaction(params, provider_id)
    return Paynet::CheckTransaction.new(params, provider_id).build_response
  end

  def cancel_transaction(params, provider_id)
    return Paynet::CancelTransaction.new(params, provider_id).build_response
  end

  def get_statement(params, provider_id)
    return Paynet::GetStatement.new(params, provider_id).build_response
  end

  def get_information(params, provider_id)
    return Paynet::GetInformation.new(params, provider_id).build_response
  end

  def check_ip
    return if Rails.env.development?
    ip_list = PAYNET_CONFIG[:ip_list]
    raise 'Not allowed' until ip_list.include? request.remote_ip
  end

  def set_log_file
    log_path = Rails.env.production? ? '/var/www/paysys/log' : "#{Rails.root}/log"
    @log_file = "#{log_path}/paynet_#{Time.zone.now.month}_#{Time.zone.now.year}.log"
    File.new(@log_file, 'w') unless File.exist?(@log_file)
  end

  def log(action_name, provider_id, request)
    set_log_file unless @log_file

    logger = ::Logger.new(@log_file)
    logger.info("------------------------- #{action_name.to_s} ----------------------")
    logger.info("#{Time.zone.now} - action:#{action_name.to_s} provider:#{provider_id} request:#{request.to_s}")
  end
end
