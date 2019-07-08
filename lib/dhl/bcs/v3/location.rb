module Dhl::Bcs::V3
  # a location is one of Address, Packstation, Postfiliale or ParcelShop
  # they have some properties in common
  class Location

    include Buildable

    PROPERTIES = %i(zip city country country_code state).freeze
    attr_accessor(*PROPERTIES)

    def to_soap_hash
      {
        'cis:zip' => zip,
        'cis:city' => city,
        'cis:Origin' => {}.tap { |h|
          h['cis:country'] = country if country
          h['cis:countryISOCode'] = country_code if country_code
          h['cis:state'] = state if state
        }
      }
    end

  end
end
