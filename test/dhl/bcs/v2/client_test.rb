require 'test_helper'

module Dhl::Bcs::V3
  class BusinessCustomerShippingTest < Minitest::Test

    def setup
      config = { user: '2222222222_01', signature: 'pass', ekp: '2222222222', participation_number: '01', api_user: 'test', api_pwd: 'test' }
      options = { test: true, log: false }
      @client = Dhl::Bcs.client(config, options)
    end

    def test_get_version_request
      stub_and_check(file_prefix: 'get_version') do
        result = @client.get_version
        assert_equal({ major_release: '2', minor_release: '0', build: '18' }, result)
      end
    end

    def test_validate_shipment_request
      shipment = Dhl::Bcs.build_shipment(
        shipper: {
          name: 'Christoph Wagner',
          company: 'webit! Gesellschaft für neue Medien mbH',
          street_name: 'Schandauer Straße',
          street_number: '34',
          zip: '01309',
          city: 'Dresden',
          country_code: 'DE',
          email: 'wagner@webit.de'
        },
        receiver: {
          name: 'John Doe',
          street_name: 'Mainstreet',
          street_number: '10',
          address_addition: 'Appartment 2a',
          zip: '90210',
          city: 'Springfield',
          country_code: 'DE',
          email: 'john.doe@example.com'
        },
        weight: 3.5,
        shipment_date: Date.new(2016, 7, 13)
      )
      stub_and_check(file_prefix: 'validate_single_shipment_errors') do
        result = @client.validate_shipment(shipment)
        assert_equal(
          [
            {
              status_code: '0',
              status_text: 'Weak validation error occured.',
              status_message: [
                'Der eingegebene Wert ist zu lang und wurde gekürzt.',
                'Die Postleitzahl konnte nicht gefunden werden.',
                'Der eingegebene Wert ist zu lang und wurde gekürzt.'
              ]
            }
          ], result)
      end

      shipment2 = valid_shipment

      stub_and_check(file_prefix: 'validate_multiple_shipments_errors') do
        result = @client.validate_shipment(shipment, shipment2)
        assert_equal(
          [
            {
              status_code: '0',
              status_text: 'Weak validation error occured.',
              status_message: [
                'Der eingegebene Wert ist zu lang und wurde gekürzt.',
                'Die Postleitzahl konnte nicht gefunden werden.',
                'Der eingegebene Wert ist zu lang und wurde gekürzt.'
              ]
            },
            {
              status_code: '0',
              status_text: 'ok',
              status_message: 'Der Webservice wurde ohne Fehler ausgeführt.'
            }
          ], result)
      end
    end

    def test_create_shipment_without_weight
      shipment = Dhl::Bcs.build_shipment(
        shipper: {
          name: 'Christoph Wagner',
          company: 'webit! Gesellschaft für neue Medien mbH',
          street_name: 'Schandauer Straße',
          street_number: '34',
          zip: '01309',
          city: 'Dresden',
          country_code: 'DE',
          email: 'wagner@webit.de'
        },
        receiver: {
          name: 'John Doe',
          street_name: 'Mainstreet',
          street_number: '10',
          address_addition: 'Appartment 2a',
          zip: '90210',
          city: 'Springfield',
          country_code: 'DE',
          email: 'john.doe@example.com'
        },
        shipment_date: Date.new(2016, 7, 13)
      )

      assert_raises Dhl::Bcs::Error do
        @client.validate_shipment(shipment)
      end
    end

    def test_create_shipment_codeable_error
      # WebMock.allow_net_connect!
      invalid_shipment = Dhl::Bcs.build_shipment(
        shipper: {
          name: 'Christoph Wagner',
          company: 'webit! Gesellschaft für neue Medien mbH',
          street_name: 'Schandauer Straße',
          street_number: '34',
          zip: '01309',
          city: 'Dresden',
          country_code: 'DE',
          email: 'wagner@webit.de'
        },
        receiver: {
          name: 'John Doe',
          street_name: 'Mainstreet',
          street_number: '10',
          address_addition: 'Appartment 2a',
          zip: '90210',
          city: 'Springfield',
          country_code: 'DE',
          email: 'john.doe@example.com'
        },
        weight: 3.5,
        shipment_date: Date.new(2016, 7, 13)
      )

      stub_and_check(file_prefix: 'create_shipment_codeable_error') do
        result = @client.create_shipment_order(invalid_shipment, print_only_if_codeable: true)
        assert_equal(
            [
              {
                :status=> {
                  status_code: '1101',
                  status_text: 'Hard validation error occured.',
                  status_message: [
                    'In der Sendung trat mindestens ein harter Fehler auf.',
                    'Die Postleitzahl konnte nicht gefunden werden.',
                    'Der eingegebene Wert ist zu lang und wurde gekürzt.'
                  ]
                }
              }
            ], result)
      end
    end

    def test_create_shipment_print_only_if_codeable
      # WebMock.allow_net_connect!
      stub_and_check(file_prefix: 'create_shipment_print_only_if_codeable') do
        result = @client.create_shipment_order(valid_shipment, print_only_if_codeable: true)
        assert_equal(
          [
            {
              status: { status_code: '0', status_text: 'ok', status_message: 'Der Webservice wurde ohne Fehler ausgeführt.' },
              shipment_number: '22222222201019582121',
              label_url: 'https://cig.dhl.de/gkvlabel/SANDBOX/dhl-vls/gw/shpmntws/printShipment?token=JD7HKktuvugIFEkhSvCfbEz4J8Ah0dkcVuw4PzBGRyRnW%2FwEPAwfytLtb31e7gMDsSX32%2BEB5exp8nNPs%2FhJSQ%3D%3D',
            }
          ], result)
      end
    end

    def test_create_shipment_order_request
      #WebMock.allow_net_connect!
      stub_and_check(file_prefix: 'create_shipment_order') do
        result = @client.create_shipment_order(valid_shipment)
        assert_equal(
          [
            {
              status: { status_code: '0', status_text: 'ok', status_message: 'Der Webservice wurde ohne Fehler ausgeführt.' },
              shipment_number: '22222222201019582121',
              label_url: 'https://cig.dhl.de/gkvlabel/SANDBOX/dhl-vls/gw/shpmntws/printShipment?token=JD7HKktuvugIFEkhSvCfbEz4J8Ah0dkcVuw4PzBGRyRnW%2FwEPAwfytLtb31e7gMDsSX32%2BEB5exp8nNPs%2FhJSQ%3D%3D',
            }
          ], result)
      end
    end

    def test_create_shipment_order_with_service_request
      stub_and_check(file_prefix: 'create_shipment_order_with_service') do
        shipment = valid_shipment
        shipment.services = [Service.new(name: 'IndividualSenderRequirement', attributes: { active: '1', details: 'Test' })]
        result = @client.create_shipment_order(shipment)
        assert_equal(
          [
            {
              status: { status_code: '0', status_text: 'ok', status_message: 'Der Webservice wurde ohne Fehler ausgeführt.' },
              shipment_number: '22222222901010000944',
              label_url: 'https://cig.dhl.de/gkvlabel/SANDBOX/dhl-vls/gw/shpmntws/printShipment?token=JD7HKktuvugIFEkhSvCfbEz4J8Ah0dkcVuw4PzBGRyRnW%2FwEPAwfytLtb31e7gMDzoWAizFLNP5lQPVuv28JYw%3D%3D'
            }
          ], result)
      end
    end

    def test_create_shipment_order_with_ident_check_service_request
      stub_and_check(file_prefix: 'create_shipment_order_with_ident_check_service') do
        shipment = valid_shipment
        shipment.services << Dhl::Bcs.build_service(name: 'IdentCheck', attributes: { active: '1' }, children: { 'Ident' => { surname: 'Doe', given_name: 'Jon Doe', date_of_birth: '1980-12-24', minimum_age: '18' } })
        result = @client.create_shipment_order(shipment)
        assert_equal(
          [
            {
              status: { status_code: '0', status_text: 'ok', status_message: 'Der Webservice wurde ohne Fehler ausgeführt.' },
              shipment_number: '22222222901010000944',
              label_url: 'https://cig.dhl.de/gkvlabel/SANDBOX/dhl-vls/gw/shpmntws/printShipment?token=JD7HKktuvugIFEkhSvCfbEz4J8Ah0dkcVuw4PzBGRyRnW%2FwEPAwfytLtb31e7gMDzoWAizFLNP5lQPVuv28JYw%3D%3D'
            }
          ], result)
      end
    end

    def test_create_shipment_order_international_packet_request
      # WebMock.allow_net_connect!
      stub_and_check(file_prefix: 'create_shipment_order_international_packet') do
        result = @client.create_shipment_order(valid_shipment_international_packet)
        assert_equal(
          [
            {
              status: { status_code: '0', status_text: 'ok', status_message: 'Der Webservice wurde ohne Fehler ausgeführt.' },
              shipment_number: '22222222201019582121',
              label_url: 'https://cig.dhl.de/gkvlabel/SANDBOX/dhl-vls/gw/shpmntws/printShipment?token=JD7HKktuvugIFEkhSvCfbEz4J8Ah0dkcVuw4PzBGRyRnW%2FwEPAwfytLtb31e7gMDsSX32%2BEB5exp8nNPs%2FhJSQ%3D%3D',
              export_label_url: 'https://cig.dhl.de/gkvlabel/SANDBOX/dhl-vls/gw/shpmntws/printShipment?token=Vfov%2BMinVhMH6nQVfvSCmNUSRNnaQNHKPaiLiWtXsqm%2BENCM6wnStB2C44rl6BEmSxbrPeaTQwBhoHBr802FnuftGVJ9uVM0C0ztLpxNfyc%3D',
            }
          ], result)
      end
    end

    def test_update_shipment_order
      stub_and_check(file_prefix: 'update_shipment_order') do
        shipment = valid_shipment
        shipment.shipper.name = 'Hans Peter'
        result = @client.update_shipment_order('22222222901010000944', shipment)
        assert_equal({
          status: { status_code: '0', status_text: 'ok', status_message: 'Der Webservice wurde ohne Fehler ausgeführt.' },
          shipment_number: '22222222901010000951',
          label_url: 'https://cig.dhl.de/gkvlabel/SANDBOX/dhl-vls/gw/shpmntws/printShipment?token=JD7HKktuvugIFEkhSvCfbEz4J8Ah0dkcVuw4PzBGRyRnW%2FwEPAwfytLtb31e7gMDt2F0qWfCk1O81BAd1GiAgw%3D%3D'
        }, result)
      end
    end

    def test_get_label_not_found
      stub_and_check(file_prefix: 'get_label_not_found') do
        result = @client.get_label('22222222901010000944')
        assert_equal({
          '22222222901010000944' => {
            status: { status_code: '2000', status_text: 'Unknown shipment number.', status_message: 'A shipment for print cannot be found' }
          }
        }, result)
      end
    end

    def test_get_label
      stub_and_check(file_prefix: 'get_label') do
        result = @client.get_label('22222222901010000951')
        assert_equal({
          '22222222901010000951' => {
            status: { status_code: '0', status_text: 'ok', status_message: 'Der Webservice wurde ohne Fehler ausgeführt.' },
            label_url: 'https://cig.dhl.de/gkvlabel/SANDBOX/dhl-vls/gw/shpmntws/printShipment?token=JD7HKktuvugIFEkhSvCfbEz4J8Ah0dkcVuw4PzBGRyRnW%2FwEPAwfytLtb31e7gMDt2F0qWfCk1O81BAd1GiAgw%3D%3D'
          }
        }, result)
      end
    end

    def test_delete_shipment_order
      stub_and_check(file_prefix: 'delete_shipment_order') do
        result = @client.delete_shipment_order('22222222901010000951')
        assert_equal({
          '22222222901010000951' => {
            status: { status_code: '0', status_text: 'ok', status_message: nil }
          }
        }, result)
      end
    end

    private

    def valid_shipment
      Dhl::Bcs.build_shipment(
        shipper: {
          name: 'Christoph Wagner',
          company: 'webit!',
          street_name: 'Schandauer Straße',
          street_number: '34',
          zip: '01309',
          city: 'Dresden',
          country_code: 'DE',
          email: 'wagner@webit.de'
        },
        receiver: {
          name: 'Jane Doe',
          street_name: 'Willy-Brandt-Straße',
          street_number: '1',
          zip: '10557',
          city: 'Berlin',
          country_code: 'DE',
          email: 'jane.doe@example.com'
        },
        weight: 3.5,
        shipment_date: Date.new(2016, 7, 13)
      )
    end

    def valid_shipment_international_packet
      Dhl::Bcs.build_shipment(
        shipper: {
          name: 'Christoph Wagner',
          company: 'webit!',
          street_name: 'Schandauer Straße',
          street_number: '34',
          zip: '01309',
          city: 'Dresden',
          country_code: 'DE',
          email: 'wagner@webit.de'
        },
        receiver: {
          name: 'Jane Doe',
          street_name: 'Bleicherweg',
          street_number: '5',
          zip: '8001',
          city: 'Zürich',
          country_code: 'CH',
          email: 'jane.doe@example.com'
        },
        weight: 3.5,
        product: 'V53WPAK',
        shipment_date: Date.new(2018, 4, 18),
        export_document: {
          invoice_number: 12345678,
          export_type: 'OTHER',
          export_type_description: 'Permanent',
          terms_of_trade: 'DDP',
          place_of_commital: 'Bonn',
          permit_number: 1234,
          attestation_number: 12345678,
          with_electronic_export_notification: true,
          export_doc_positions: [
            {
              description: 'ExportPositionOne',
              country_code_origin: 'CN',
              customs_tariff_number: 12345678,
              amount: 1,
              net_weight_in_kg: 0.2,
              customs_value: 24.96
            },
            {
              description: 'ExportPositionTwo',
              country_code_origin: 'CN',
              customs_tariff_number: 12345678,
              amount: 1,
              net_weight_in_kg: 0.4,
              customs_value: 99.90
            }
          ]
        }
      )
    end

    def stub_and_check(method: :post, url: 'https://cig.dhl.de/services/sandbox/soap', file_prefix: '')
      stub_request(method, url).to_return(status: 200, body: File.read("test/stubs/#{file_prefix}_response.xml"))

      # use Nokogiri to remove all whitespaces between the xml tags
      request_xml =
        Nokogiri::XML.parse(File.read("test/stubs/#{file_prefix}_request.xml"), &:noblanks).
        to_xml(save_with: Nokogiri::XML::Node::SaveOptions::AS_XML).sub("\n", '').strip

      yield
      assert_requested method, url, body: request_xml
    end

  end
end
