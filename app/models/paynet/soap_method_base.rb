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

    attr_accessor :params

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

    #TODO:: authenticated?
    def authenticated?
      method_arguments['username'] == 'TomUz2014' && method_arguments['password'] == 'tom10v000317'
    end

    def to_bool(text)
      return true if text =~ (/^(true)$/i)
      return false if text =~ (/^(false)$/i)
      raise ArgumentError.new("invalid value for Boolean: \"#{text}\"")
    end
  end

end
