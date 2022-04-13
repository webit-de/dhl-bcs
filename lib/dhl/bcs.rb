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
require 'dhl/bcs/v2/locator'
require 'dhl/bcs/v2/export_document'

module Dhl
  module Bcs

    def self.client(config, **options)
      V2::Client.new(config, **options)
    end

    def self.build_shipment(**opts)
      V2::Shipment.build(**opts)
    end

    def self.build_shipper(**opts)
      V2::Shipper.build(**opts)
    end

    def self.build_receiver(**opts)
      V2::Receiver.build(**opts)
    end

    def self.build_service(**opts)
      V2::Service.new(**opts)
    end

  end
end
