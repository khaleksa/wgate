class ClickController < ApplicationController
  skip_before_action :verify_authenticity_token

  ACTIONS = { prepare: 0, complete: 1 }
  SECRET_KEY = 'dfsdfsdfsdfsf' #TODO: move to providers table
  CLICK_STATUS_OK = 0
  CLICK_MIN_AMOUNT = 0
  STATUS_MESSAGES = {
    0 => 'Success',
    -1 => 'SIGN CHECK FAILED!',
    -2 => 'Incorrect parameter amount',
    -3 => 'Action not found',
    -4 => 'Already paid',
    -5 => 'User does not exist',
    -6 => 'Transaction does not exist',
    -7 => 'Failed to update user',
    -8 => 'Error in request from click',
    -9 => 'Transaction cancelled',
    -10 => 'This transaction has been already approved',
    -11 => 'Unknown error',
    -12 => 'Failed to create transaction',
  }

  def sync
    click_data = click_params
    if click_data[:action].present?
      if click_data[:action].to_i == ACTIONS[:prepare]
        action_response = prepare(click_data)
      elsif click_data[:action].to_i == ACTIONS[:complete]
        action_response = complete(click_data)
      end
    end
    action_response = error_response(-3) if action_response.blank?

    render json: action_response
  end

  def prepare(click_data)
    response = verify_prepare_data(click_data)
    return response if response.present?

    transaction = build_transaction!(click_data)
    if transaction.try(:persisted?)
      {
          merchant_trans_id: transaction.account_id,
          merchant_prepare_id: transaction.id,
          error: 0,
          error_note:  STATUS_MESSAGES[0],
      }.to_json
    else
      error_response(-12)
    end
  rescue
    error_response(-11)
  end

  def complete(click_data)
    response = verify_complete_data(click_data)
    return response if response.present?

    transaction = ClickTransaction.find_by_click_id(click_data[:click_trans_id].to_i)
    return error_response(-6) unless transaction

    return error_response(-8) unless transaction.id == click_data[:merchant_prepare_id]
    return error_response(-8) unless transaction.amount.to_d == click_data[:amount].to_d

    if (click_data[:error].to_i == 0)
      return error_response(-4) if transaction.commited?
      transaction.commit
    else
      return error_response(-10) if transaction.cancelled?
      transaction.cancel
    end
    transaction.save!

    {
        merchant_trans_id: transaction.account_id,
        merchant_confirm_id: transaction.id,
        error: 0,
        error_note: STATUS_MESSAGES[0],
    }.to_json
  rescue
    error_response(-11)
  end

  private
  def click_params
    request.raw_post.split(/&/).inject({}) do |hash, setting|
      key, val = setting.split(/=/)
      hash[key.to_sym] = val
      hash
    end
  end

  def error_response(error_code)
    {
      error: error_code,
      error_note: STATUS_MESSAGES[error_code],
    }.to_json
  end

  def verify_prepare_data(click_data)
    prepare_request_params = [:click_trans_id, :service_id, :merchant_trans_id, :amount, :action, :error, :error_note, :sign_time, :sign_string]
    missing_param = prepare_request_params.detect { |k| !click_data.has_key?(k) }
    return error_response(-2) if missing_param.present?

    #TODO: should I check error param for prepare action???
    return error_response(-8) unless click_data[:error].to_i == 0

    sign = Digest::MD5.hexdigest(click_data[:click_trans_id] +
                                 click_data[:service_id] +
                                 SECRET_KEY +
                                 click_data[:merchant_trans_id] +
                                 click_data[:amount] +
                                 click_data[:action] +
                                 click_data[:sign_time])
    return error_response(-1) unless sign == click_data[:sign_string]

    return error_response(-8) if click_data[:amount].to_d <= CLICK_MIN_AMOUNT

    #TODO: if user account-merchant_trans_id doesn't exist
    user = true
    return error_response(-5) unless user

    transaction = ClickTransaction.find_by_click_id(click_data[:click_trans_id].to_i)
    return error_response(-4) if transaction && transaction.commited?
  end

  def verify_complete_data(click_data)
    complete_request_params = [:click_trans_id, :service_id, :merchant_trans_id, :merchant_prepare_id, :amount,
                               :action, :error, :error_note, :sign_time, :sign_string]
    missing_param = complete_request_params.detect { |k| !click_data.has_key?(k) }
    return error_response(-2) if missing_param.present?

    #TODO: check it!
    return error_response(-8) unless click_data[:error].to_i == 0 || click_data[:error].to_i == -4356

    sign = Digest::MD5.hexdigest(click_data[:click_trans_id] +
                                 click_data[:service_id] +
                                 SECRET_KEY +
                                 click_data[:merchant_trans_id] +
                                 click_data[:merchant_prepare_id] +
                                 click_data[:amount] +
                                 click_data[:action] +
                                 click_data[:sign_time])
    return error_response(-1) unless sign == click_data[:sign_string]

    #TODO: if user account-merchant_trans_id doesn't exist
    user = true
    return error_response(-5) unless user
  end

  def parse_date(date)
    Time.zone.parse(date.to_s)
  rescue ArgumentError
    #TODO: add record to log file
    Time.zone.now
  end

  def build_transaction!(click_data)
    args = {
        click_id: click_data[:click_trans_id].to_i,
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
end
