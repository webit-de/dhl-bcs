require 'dhl/bcs/version'
require 'dhl/bcs/errors'
require 'dhl/bcs/v3/client'
require 'dhl/bcs/v3/buildable'
require 'dhl/bcs/v3/shipment'
require 'dhl/bcs/v3/shipper'
require 'dhl/bcs/v3/receiver'
require 'dhl/bcs/v3/communication'
require 'dhl/bcs/v3/location'
require 'dhl/bcs/v3/address'
require 'dhl/bcs/v3/packstation'
require 'dhl/bcs/v3/parcel_shop'
require 'dhl/bcs/v3/postfiliale'
require 'dhl/bcs/v3/bank_data'
require 'dhl/bcs/v3/service'
require 'dhl/bcs/v3/locator'
require 'dhl/bcs/v3/export_document'

module Dhl
  module Bcs

    def self.client(config, options = {})
      V3::Client.new(config, options)
    end

    def self.build_shipment(*args)
      V3::Shipment.build(*args)
    end

    def self.build_shipper(*args)
      V3::Shipper.build(*args)
    end

    def self.build_receiver(*args)
      V3::Receiver.build(*args)
    end

    def self.build_service(*args)
      V3::Service.new(*args)
    end

  end
end
