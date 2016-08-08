require 'dhl/bcs/version'
require 'dhl/bcs/errors'
require 'dhl/bcs/v2/client'
require 'dhl/bcs/v2/buildable'
require 'dhl/bcs/v2/shipment'
require 'dhl/bcs/v2/shipper'
require 'dhl/bcs/v2/receiver'
require 'dhl/bcs/v2/communication'
require 'dhl/bcs/v2/location'
require 'dhl/bcs/v2/address'
require 'dhl/bcs/v2/packstation'
require 'dhl/bcs/v2/parcel_shop'
require 'dhl/bcs/v2/postfiliale'
require 'dhl/bcs/v2/bank_data'
require 'dhl/bcs/v2/service'

module Dhl
  module Bcs

    def self.client(config, options = {})
      V2::Client.new(config, options)
    end

    def self.build_shipment(*args)
      V2::Shipment.build(*args)
    end

    def self.build_shipper(*args)
      V2::Shipper.build(*args)
    end

    def self.build_receiver(*args)
      V2::Receiver.build(*args)
    end

    def self.build_service(*args)
      V2::Service.new(*args)
    end

  end
end
