module Dhl::Bcs::V3
  class Address < Location

    ADD_PROPS = %i(company company_addition street_name street_number address_addition dispatching_information).freeze
    PROPERTIES = Location::PROPERTIES + ADD_PROPS
    attr_accessor(*ADD_PROPS)

    def to_soap_hash
      h = {}
      h['cis:name2'] = company if company
      h['cis:name3'] = company_addition if company_addition
      h['cis:streetName'] = street_name
      h['cis:streetNumber'] = street_number
      h['cis:addressAddition'] = address_addition if address_addition
      h['cis:dispatchingInformation'] = dispatching_information if dispatching_information
      h.merge(super)
    end

  end
end
