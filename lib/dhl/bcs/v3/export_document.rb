module Dhl::Bcs::V3
  class ExportDocument
    include Buildable

    PROPERTIES = %i(invoice_number export_type export_type_description terms_of_trade place_of_commital additional_fee permit_number attestation_number with_electronic_export_notification export_doc_positions).freeze
    attr_accessor(*PROPERTIES)

    EXPORT_TYPES = %w(OTHER PRESENT COMMERCIAL_SAMPLE DOCUMENT RETURN_OF_GOODS).freeze
    TERMS_OF_TRADES = %w(DDP DXV DDU DDX).freeze

    def self.build(export_doc_positions = [], **attributes)
      array_of_export_doc_positions = []
      export_doc_positions.each do |export_doc_position|
        array_of_export_doc_positions << ExportDocPosition.build(export_doc_position) if export_doc_position.is_a?(Hash)
      end
      new({ export_doc_positions: array_of_export_doc_positions }.merge(attributes))
    end

    def initialize(**attributes)
      attributes.each do |property, value|
        send("#{property}=", value) if PROPERTIES.include?(property)
      end
    end

    def export_type=(export_type)
      raise Dhl::Bcs::Error, "No Valid export_type #{export_type}, Please use one of these: #{EXPORT_TYPES.join(',')}" unless EXPORT_TYPES.include?(export_type)
      @export_type = export_type
    end

    def terms_of_trade=(terms_of_trade)
      raise Dhl::Bcs::Error, "No Valid terms_of_trade #{terms_of_trade}, Please use one of these: #{TERMS_OF_TRADES.join(',')}" unless TERMS_OF_TRADES.include?(terms_of_trade)
      @terms_of_trade = terms_of_trade
    end

    def to_soap_hash
      raise Dhl::Bcs::Error, "export_doc_position must be set as an array." unless export_doc_positions
      raise Dhl::Bcs::Error, "export_type_desription must be set, as export_type is set to OTHER." unless !((export_type == 'OTHER') ^ export_type_description)
      raise Dhl::Bcs::Error, "place_of_commital must be set" unless place_of_commital
      h = {}
      h['invoiceNumber'] = invoice_number if invoice_number
      h['exportType'] = export_type
      h['exportTypeDescription'] = export_type_description if export_type_description
      h['termsOfTrade'] = terms_of_trade if terms_of_trade
      h['placeOfCommital'] = place_of_commital
      h['additionalFee'] = additional_fee if additional_fee
      h['permitNumber'] = permit_number if permit_number
      h['attestationNumber'] = attestation_number if attestation_number
      h['WithElectronicExportNtfctn/'] = {'@active': 1} if with_electronic_export_notification
      h['ExportDocPosition'] = self.export_doc_positions.map { |e| e.to_soap_hash }
      h
    end
  end

  class ExportDocPosition
    PROPERTIES = %i(description country_code_origin customs_tariff_number amount net_weight_in_kg customs_value).freeze
    attr_accessor(*PROPERTIES)

    include Buildable

    def initialize(**attributes)
      attributes.each do |property, value|
        send("#{property}=", value) if PROPERTIES.include?(property)
      end
    end

    def to_soap_hash
      raise Dhl::Bcs::Error, 'export doc position description must be set' unless description
      raise Dhl::Bcs::Error, 'export doc position country_code_origin must be set'  unless country_code_origin
      raise Dhl::Bcs::Error, 'export doc position customs_tariff_number must be set' unless customs_tariff_number
      raise Dhl::Bcs::Error, 'export doc position amount must be set' unless amount
      raise Dhl::Bcs::Error, 'export doc position net_weight_in_kg must be set' unless net_weight_in_kg
      raise Dhl::Bcs::Error, 'export doc position customs_value must be set' unless customs_value
      {
        'description' => description,
        'countryCodeOrigin' => country_code_origin,
        'customsTariffNumber' => customs_tariff_number,
        'amount' => amount,
        'netWeightInKG' => net_weight_in_kg,
        'customsValue' => customs_value
      }
    end

  end
end
