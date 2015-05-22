# encoding: utf-8

module Paynet

  class GetInformation < SoapMethodBase

    def build_response
      timestamp = Time.zone.now
      user_name = @response_status == 0 ? provider.find_user_by(user_account).try(:full_name) : 'Unknown'
    rescue => exception
      log("GetInformation#build_response Error: #{exception.message}")
      @response_status = 102
    ensure
      response_params = {
          errorMsg: STATUS_MESSAGES[@response_status],
          status: @response_status,
          timeStamp: timestamp.strftime(DATE_FORMAT),
          parameters: pack_params(:param_key   => 'name', :param_value => user_name)
      }
      log_params(response_params)
      return envelope('GetInformationResult', pack_params(response_params))
    end

    private
    def user_account
      method_arguments['parameters']['paramValue'].strip
    end

    def validate_status
      return 411 unless params_valid?
      return 412 unless authenticated?
      return 302 unless provider.find_user_by(user_account)

      return 0
    end

    def log_params(response_params)
      data = "#{Time.zone.now} - account_id:#{user_account} response_params:#{response_params.to_s}"
      log(data)
    end
  end

end
