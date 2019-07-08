module Dhl::Bcs::V3
  class Communication

    include Buildable

    PROPERTIES = %i(phone email contact_person).freeze
    attr_accessor(*PROPERTIES)

    def to_soap_hash
      {}.tap do |h|
        h['cis:phone'] = phone if phone
        h['cis:email'] = email if email
        h['cis:contactPerson'] = contact_person if contact_person
      end
    end

  end
end
