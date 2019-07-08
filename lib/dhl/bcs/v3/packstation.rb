module Dhl::Bcs::V3
  class Packstation < Location

    ADD_PROPS = %i(post_number packstation_number).freeze
    PROPERTIES = Location::PROPERTIES + ADD_PROPS
    attr_accessor(*ADD_PROPS)

    def to_soap_hash
      h = {}
      h['postNumber'] = post_number if post_number
      h['packstationNumber'] = packstation_number
      h.merge(super)
    end

  end
end
