module Dhl::Bcs::V3
  class Service

    include Buildable

    PROPERTIES = %i(name attributes children).freeze
    attr_accessor(*PROPERTIES)

    def to_soap_hash
      # make a self closing tag by appending "/" if no children
      tag_name = children ? name : "#{name}/"
      { tag_name => children, attributes!: { tag_name => attributes } }
    end

  end
end
