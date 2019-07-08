module Dhl::Bcs::V3
  # finds proper class from attributes and builds object
  class Locator

    def self.for(attributes = {})
      location_class = location_class_finder(attributes)
      location_builder(attributes, location_class: location_class)
    end

    def self.location_class_finder(attributes)
      if attributes.key?(:packstation_number)
        Packstation
      elsif attributes.key?(:postfilial_number)
        Postfiliale
      elsif attributes.key?(:parcel_shop_number)
        ParcelShop
      else
        Address
      end
    end

    def self.location_builder(attributes = {}, location_class: Address)
      location_class.build(attributes)
    end

  end
end
