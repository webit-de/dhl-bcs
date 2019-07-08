require 'test_helper'

module Dhl::Bcs::V3
  class ShipperTest < Minitest::Test

    def test_build_shipper
      shipper = Shipper.build(
        name: 'Christoph Wagner',
        company: 'webit! Gesellschaft für neue Medien mbH',
        street_name: 'Schandauer Straße',
        street_number: '34',
        zip: '01309',
        city: 'Dresden',
        country_code: 'DE',
        email: 'wagner@webit.de'
      )

      assert_equal 'Christoph Wagner', shipper.name
      assert_equal 'webit! Gesellschaft für neue Medien mbH', shipper.company

      address = shipper.address
      assert_equal 'Schandauer Straße', address.street_name
      assert_equal '34', address.street_number
      assert_equal '01309', address.zip
      assert_equal 'Dresden', address.city
      assert_equal 'DE', address.country_code

      assert_equal 'wagner@webit.de', shipper.communication.email

      shipper2 = Shipper.build(
        name: 'John',
        company: 'webit! Gesellschaft für neue Medien mbH',
        address: address,
        communication: {
          email: 'john@webit.de',
          phone: '0123456'
        },
        phone: '65245'
      )

      assert_equal 'John', shipper2.name
      assert_equal address, shipper2.address
      assert_equal '0123456', shipper2.communication.phone
    end

  end
end
