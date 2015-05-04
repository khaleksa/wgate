# encoding: utf-8

module Paynet

  class SoapMethodBase
    STATUS_MESSAGES = {
        0 => 'Успешно.',
        102 => 'Системная ошибка.',
        103 => 'Транзакция не найдена.',
        201 => 'Транзакция уже существует.',
        202 => 'Транзакция уже отменена.',
        302 => 'Клиент не найден.',
        411 => 'Не заданы один или несколько обязательных параметров.',
        412 => 'Неверный логин.',
        413 => 'Неверная сумма. Минимальная сумма - 1000 сум.',
        414 => 'Неверный формат даты и времени.'
    }

    attr_accessor :params, :provider

    def initialize(params, provider_id)
      @params = params

      begin
        @provider = Provider.find(provider_id)
      rescue => exception
        log("Error: #{exception.message}")
        @response_status = 102
      end

      @response_status = validate_status unless @response_status
    end

    private
    def pack_params(args = {})
      args.map { |k, v| "<#{k}>#{v}</#{k}>\n" }.join
    end

    def envelope(name, body)
      "<soapenv:Envelope xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/'>\n<soapenv:Body>\n" +
        "<ns1:#{name} xmlns:ns1='http://uws.provider.com/' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>\n" +
        body +
        "</ns1:#{name}>\n" +
        "</soapenv:Body>\n</soapenv:Envelope>"
    end

    def method_arguments
      params['Envelope']['Body'][params['Envelope']['Body'].keys.first]
    end

    def params_valid?
      params['Envelope'].present? && params['Envelope']['Body'].present? && method_arguments.present?
    end

    def authenticated?
      user_name = provider.paynet_params['user_name']
      password = provider.paynet_params['password']
      method_arguments['username'] == user_name && method_arguments['password'] == password
    end

    def to_bool(text)
      return true if text =~ (/^(true)$/i)
      return false if text =~ (/^(false)$/i)
      raise ArgumentError.new("invalid value for Boolean: \"#{text}\"")
    end

    def log(data)
      ::Logger.new("#{Rails.root}/log/paynet_#{Time.zone.now.month}_#{Time.zone.now.year}.log").info(data)
    end
  end

end
