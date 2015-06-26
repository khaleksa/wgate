class Click::BasesController < ApplicationController
  skip_before_action :verify_authenticity_token

  ACTIONS = {
      prepare: 0,
      complete: 1
  }
  CLICK_MIN_AMOUNT = 0
  CLICK_STATUS_OK = 0
  STATUS_MESSAGES = {
      0 => 'Success',                      # Успешный запрос
      -1 => 'SIGN CHECK FAILED!',          # Ошибка проверки подписи
      -2 => 'Incorrect parameter amount',  # Неверная сумма оплаты
      -3 => 'Action not found',            # Запрашиваемое действие не найдено
      -4 => 'Already paid',                # Транзакция ранее была подтверждена (при попытке подтвердить или отменить ранее подтвержденную транзакцию)
      -5 => 'User does not exist',         # Не найдет пользователь/заказ (проверка параметра merchant_trans_id)
      -6 => 'Transaction does not exist',  # Не найдена транзакция (проверка параметра merchant_prepare_id)
      -7 => 'Failed to update user',       # Ошибка при изменении данных пользователя (изменение баланса счета и т.п.)
      -8 => 'Error in request from click', # Ошибка в запросе от CLICK (переданы не все параметры и т.п.)
      -9 => 'Transaction cancelled'        # Транзакция ранее была отменена (При попытке подтвердить или отменить ранее отмененную транзакцию)
  }

  def sync
    click_data = click_params
    response = process_click_action(click_data)
    log_params(click_data, response)
    render json: response
  end

  def set_provider(provider_id)
    @provider = Provider.find(provider_id)
  end

  private
  def process_click_action(click_data)
    return error_response(-8) unless click_data[:action].present?
    return error_response(-3) unless ACTIONS.values.include?(click_data[:action].to_i)
    click_data[:action].to_i == ACTIONS[:prepare] ? click_action_prepare(click_data) : click_action_complete(click_data)
  end

  def click_action_prepare(click_data)
    response = verify_prepare_data(click_data)
    return response if response.present?

    transaction = build_transaction!(click_data)
    if transaction.try(:persisted?)
      {
          click_trans_id: transaction.click_id,
          merchant_trans_id: transaction.account_id,
          merchant_prepare_id: transaction.id,
          error: 0,
          error_note:  STATUS_MESSAGES[0],
      }.to_json
    else
      error_response(-7)
    end
  rescue => exception
    error_response(-7)
    log("Click::BasesController#click_action_prepare Error: #{exception.message}")
  end

  def verify_prepare_data(click_data)
    prepare_request_params = [:click_trans_id, :service_id, :merchant_trans_id, :amount, :action, :error, :error_note, :sign_time, :sign_string]
    missing_param = prepare_request_params.detect { |k| !click_data.has_key?(k) }
    return error_response(-8) if missing_param.present?

    return error_response(-9) unless click_data[:error].to_i == CLICK_STATUS_OK

    sign = Digest::MD5.hexdigest(click_data[:click_trans_id] +
                                 click_data[:service_id] +
                                 @provider.click_params['secret_key'] +
                                 click_data[:merchant_trans_id] +
                                 click_data[:amount] +
                                 click_data[:action] +
                                 click_data[:sign_time])
    return error_response(-1) unless sign == click_data[:sign_string]

    return error_response(-2) if click_data[:amount].to_d <= CLICK_MIN_AMOUNT

    return error_response(-5) unless @provider.find_user_by_account(click_data[:merchant_trans_id])

    transaction = ClickTransaction.find_by_click_id(click_data[:click_trans_id].to_i)
    return error_response(-4) if transaction.try(:commited?)
    return error_response(-9) if transaction.try(:cancelled?)
  end

  def click_action_complete(click_data)
    response = verify_complete_data(click_data)
    return response if response.present?

    transaction = ClickTransaction.find(click_data[:merchant_prepare_id].to_i)
    return error_response(-6) unless transaction && transaction.click_id == click_data[:click_trans_id].to_i

    return error_response(-2) unless transaction.amount.to_d == click_data[:amount].to_d

    if (click_data[:error].to_i == 0)
      return error_response(-4) if transaction.commited?
      transaction.commit
      transaction.save!

      return {
          click_trans_id: transaction.click_id,
          merchant_trans_id: transaction.account_id,
          merchant_confirm_id: transaction.id,
          error: 0,
          error_note: STATUS_MESSAGES[0],
      }.to_json
    else
      unless transaction.cancelled?
        transaction.cancel
        transaction.save!
      end
      return error_response(-9)
    end
  rescue => exception
    error_response(-7)
    log("Click::BasesController#click_action_complete Error: #{exception.message}")
  end

  def verify_complete_data(click_data)
    complete_request_params = [:click_trans_id, :service_id, :merchant_trans_id, :merchant_prepare_id,
                               :amount, :action, :error, :error_note, :sign_time, :sign_string]
    missing_param = complete_request_params.detect { |k| !click_data.has_key?(k) }
    return error_response(-8) if missing_param.present?

    sign = Digest::MD5.hexdigest(click_data[:click_trans_id] +
                                 click_data[:service_id] +
                                 @provider.click_params['secret_key'] +
                                 click_data[:merchant_trans_id] +
                                 click_data[:merchant_prepare_id] +
                                 click_data[:amount] +
                                 click_data[:action] +
                                 click_data[:sign_time])
    return error_response(-1) unless sign == click_data[:sign_string]

    return error_response(-5) unless @provider.find_user_by_account(click_data[:merchant_trans_id])
  end

  def build_transaction!(click_data)
    args = {
        click_id: click_data[:click_trans_id].to_i,
        provider_id: @provider.id,
        click_paydoc_id: click_data[:click_paydoc_id].to_i,
        service_id: click_data[:service_id].to_i,
        account_id: click_data[:merchant_trans_id],
        amount: click_data[:amount].to_f,
        action: click_data[:action].to_i,
        click_error: click_data[:error].to_i,
        click_error_note: click_data[:error_note],
        click_timestamp: parse_date(click_data[:sign_time])
    }
    ClickTransaction.create!(args)
  end

  def click_params
    request.raw_post.split(/&/).inject({}) do |hash, setting|
      key, val = setting.split(/=/)
      hash[key.to_sym] = val.present? ? CGI.unescape(val) : ''
      hash
    end
  end

  def error_response(error_code)
    {
        error: error_code,
        error_note: STATUS_MESSAGES[error_code],
    }.to_json
  end

  def log_params(params, response)
    data = "------------------ click_trans_id=#{params[:click_trans_id]} ------------------\n"
    data += "click_params:#{params.to_s}\n"
    data += "pays_response:#{response.to_s}\n"
    log(data)
  end

  def set_log_file
    log_path = Rails.env.production? ? '/var/www/paysys/log' : "#{Rails.root}/log"
    @log_file = "#{log_path}/click_#{Time.zone.now.month}_#{Time.zone.now.year}.log"
    File.new(@log_file, 'w') unless File.exist?(@log_file)
  end

  def log(data)
    set_log_file unless @log_file
    ::Logger.new(@log_file).info(data)
  end
end
