require 'base64'
require 'liqpay/base_operation'

module Liqpay
  class Response < BaseOperation
    SUCCESS_STATUSES = %w(success wait_lc wait_accept)

    ATTRIBUTES = %w(public_key order_id amount currency description type status transaction_id sender_phone)
    %w(public_key order_id description type).each do |attr|
      attr_reader attr
    end

    # Amount of payment. MUST match the requested amount
    attr_reader :amount
    # Currency of payment. MUST match the requested currency
    attr_reader :currency
    # Status of payment. One of '
    #   failure 
    #   success
    #   wait_secure - payment is checking now. You'll receive an answer in server callback and it can be success or failure or even reversed
    #   wait_accept - success, but DO NOT use your merchant before approval
    #   wait_lc - specific status for letter of credit
    attr_reader :status
    # LiqPAY's internal transaction ID
    attr_reader :transaction_id
    # Payer's phone
    attr_reader :sender_phone

    def initialize(params = {}, options = {})
      super(options)

      ATTRIBUTES.each do |attribute|
        instance_variable_set "@#{attribute}", params[attribute]
      end
      @request_signature = params["signature"]

      decode!
    end

    # Returns true, if the transaction was successful
    def success?
      SUCCESS_STATUSES.include? self.status
    end

    def signature_fields
      [amount, currency, public_key, order_id, type, description, status, transaction_id, sender_phone]
    end

  private
    def decode!
      if signature != @request_signature
        raise Liqpay::InvalidResponse
      end
    end
  end
end
