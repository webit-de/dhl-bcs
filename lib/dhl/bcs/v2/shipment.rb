module Dhl::Bcs::V2
  class Shipment

    attr_accessor :shipper, :receiver, :bank_data, :shipment_date, :product,
                  :customer_reference, :services, :weight, :length, :height, :width,
                  :notification_email

    PRODUCT_PROCEDURE_NUMBERS = {
      'V01PAK' => '01', # Paket National
      'V53WPAK' => '53', # Weltpaket
      'V54EPAK' => '54', # Europaket
      'V06TG' => '01', # Kurier Taggleich
      'V06WZ' => '01', # Kurier Wunschzeit
      'V86PARCEL' => '86', # DHL Paket Austria
      'V87PARCEL' => '87', # DHL PAKET Connect
      'V82PARCEL' => '82' # DHL PAKET International
    }.freeze
    PRODUCTS = PRODUCT_PROCEDURE_NUMBERS.keys.freeze

    # build a shipment from hash data
    def self.build(shipper:, receiver:, bank_data: nil, **shipment_attributes)
      shipper = Shipper.build(shipper) if shipper.is_a?(Hash)
      receiver = Receiver.build(receiver) if receiver.is_a?(Hash)
      bank_data = BankData.build(bank_data) if bank_data.is_a?(Hash)
      new({ shipper: shipper, receiver: receiver, bank_data: bank_data }.merge(shipment_attributes))
    end

    def initialize(attributes = {})
      assign_attributes(
        {
          product: 'V01PAK',
          shipment_date: Date.today,
          services: []
        }.merge(attributes)
      )
    end

    def assign_attributes(attributes)
      attributes.each do |key, value|
        setter = :"#{key}="
        send(setter, value) if respond_to?(setter)
      end
    end

    def product=(product)
      raise Error, "No valid product code #{product}. Please use one of these: #{PRODUCTS.join(', ')}" unless PRODUCTS.include?(product)
      @product = product
    end

    def to_soap_hash(ekp, participation_number)
      raise Error, 'Packing weight in kilo must be set!' unless weight
      raise Error, 'Sender address must be set!' unless shipper
      raise Error, 'Receiver address must be set!' unless receiver
      raise Error, 'Product must be set!' unless product

      account_number = "#{ekp}#{PRODUCT_PROCEDURE_NUMBERS[product]}#{participation_number}"
      raise Error, 'Need a 14 character long account number. Check EKP and participation_number' if account_number.size != 14
      {
        'ShipmentDetails' => {}.tap { |h|
          h['product'] = product
          h['shipmentDate'] = shipment_date.strftime("%Y-%m-%d")
          h['cis:accountNumber'] = account_number
          h['customerReference'] = customer_reference if !customer_reference.blank?

          # just one ShipmentItem possible
          h['ShipmentItem'] = { 'weightInKG' => weight }.tap { |si|
            si['lengthInCM'] = length if length
            si['widthInCM'] = width if width
            si['heightInCM'] = height if height
          }
          h['Service'] = services.map(&:to_soap_hash) unless services.empty?
          h['Notification'] = { 'recipientEmailAddress' => notification_email } if notification_email
          h['BankData'] = bank_data.to_soap_hash if bank_data
        },
        # Shipper information
        'Shipper' => shipper.to_soap_hash,
        # Receiver information
        'Receiver' => receiver.to_soap_hash
      }
    end

  end
end
