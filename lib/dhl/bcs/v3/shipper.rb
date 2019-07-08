module Dhl::Bcs::V3
  class Shipper

    PROPERTIES = %i(name company company_addition address communication).freeze

    attr_accessor(*PROPERTIES)

    def self.build(company: nil, **attributes)
      address = Address.build(attributes)
      communication = Communication.build(attributes)
      new(attributes.merge(address: address, communication: communication, company: company))
    end

    def initialize(**attributes)
      attributes.each do |property, value|
        send("#{property}=", value) if PROPERTIES.include?(property)
      end
    end

    def to_soap_hash
      {
        'Name' => { 'cis:name1' => name }.tap { |h|
          h['cis:name2'] = company if company
          h['cis:name3'] = company_addition if company_addition
        },
        'Address' => address.to_soap_hash,
        'Communication' => communication.to_soap_hash
      }
    end

  end
end
