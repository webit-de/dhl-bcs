module Dhl::Bcs::V3
  class ParcelShop < Location

    ADD_PROPS = %i(parcel_shop_number street_name street_number).freeze
    PROPERTIES = Location::PROPERTIES + ADD_PROPS
    attr_accessor(*ADD_PROPS)

    def to_soap_hash
      h = {}
      h['parcelShopNumber'] = parcel_shop_number
      h['cis:streetName'] = street_name if street_name
      h['cis:streetNumber'] = street_number if street_number
      h.merge(super)
    end

  end
end
