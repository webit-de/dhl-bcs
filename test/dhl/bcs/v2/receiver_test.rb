require 'test_helper'

module Dhl::Bcs::V3
  class ReceiverTest < Minitest::Test

    def test_build_receiver
      receiver = Receiver.build(
        name: 'John Doe',
        street_name: 'Mainstreet',
        street_number: '10',
        address_addition: 'Appartment 2a',
        zip: '90210',
        city: 'Springfield',
        country_code: 'DE',
        email: 'john.doe@example.com'
      )

      assert_equal 'John Doe', receiver.name

      address = receiver.location
      assert_equal Address, address.class
      assert_equal 'Mainstreet', address.street_name
      assert_equal '10', address.street_number
      assert_equal 'Appartment 2a', address.address_addition
      assert_equal '90210', address.zip
      assert_equal 'Springfield', address.city
      assert_equal 'DE', address.country_code

      assert_equal 'john.doe@example.com', receiver.communication.email

      receiver2 = Receiver.build(
        name: 'Joe',
        address: address,
        email: 'joe@example.com'
      )

      address = receiver2.location
      assert_equal Address, address.class
      assert_equal 'Mainstreet', address.street_name
      assert_equal '10', address.street_number
      assert_equal 'Appartment 2a', address.address_addition
      assert_equal '90210', address.zip
      assert_equal 'Springfield', address.city
      assert_equal 'DE', address.country_code

      assert_equal 'joe@example.com', receiver2.communication.email

      receiver3 = Receiver.build(
        name: 'Anon',
        street_name: 'Parcelstreet',
        street_number: '23',
        parcel_shop_number: '42',
        zip: '90210',
        city: 'Springfield',
        country_code: 'DE',
        email: 'parcel@example.com'
      )

      parcel_shop = receiver3.location
      assert_equal ParcelShop, parcel_shop.class
      assert_equal '42', parcel_shop.parcel_shop_number
      assert_equal 'Parcelstreet', parcel_shop.street_name
      assert_equal '23', parcel_shop.street_number
      assert_equal '90210', parcel_shop.zip
      assert_equal 'Springfield', parcel_shop.city
      assert_equal 'DE', parcel_shop.country_code
    end

  end
end
