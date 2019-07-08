module Dhl::Bcs::V3
  class Postfiliale < Location

    ADD_PROPS = %i(postfilial_number post_number).freeze
    PROPERTIES = Location::PROPERTIES + ADD_PROPS
    attr_accessor(*ADD_PROPS)

    def to_soap_hash
      h = {}
      h['postfilialNumber'] = postfilial_number
      h['postNumber'] = post_number
      h.merge(super)
    end

  end
end
