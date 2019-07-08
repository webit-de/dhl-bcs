require 'test_helper'

module Dhl::Bcs::V3
  class ExportDocumentTest < Minitest::Test

    def test_build_export_document
      export_document = ExportDocument.build(
        [
          {
            description: 'ExportPositionOne',
            country_code_origin: 'CN',
            customs_tariff_number: '12345678',
            amount: '1',
            net_weight_in_kg: '0.2',
            customs_value: '24.96'
          },
          {
            description: 'ExportPositionTwo',
            country_code_origin: 'CN',
            customs_tariff_number: '12345678',
            amount: '1',
            net_weight_in_kg: '0.4',
            customs_value: '99.90'
          }
        ],
        {
          invoice_number: '12345678',
          export_type: 'OTHER',
          export_type_description: 'Permanent',
          terms_of_trade: 'DDP',
          place_of_commital: 'Bonn',
          additional_fee: '1',
          permit_number: '1234',
          attestation_number: '12345678',
          with_electronic_export_notification: true
        }
      )

      assert_equal '12345678', export_document.invoice_number
      assert_equal 'OTHER', export_document.export_type
      assert_equal 'Permanent', export_document.export_type_description
      assert_equal 'DDP', export_document.terms_of_trade
      assert_equal 'Bonn', export_document.place_of_commital
      assert_equal '1', export_document.additional_fee
      assert_equal '1234', export_document.permit_number
      assert_equal '12345678', export_document.attestation_number
      assert_equal true , export_document.with_electronic_export_notification
      assert_equal 2, export_document.export_doc_positions.count


      export_doc_position = export_document.export_doc_positions.first
      assert_equal 'ExportPositionOne', export_doc_position.description
      assert_equal 'CN', export_doc_position.country_code_origin
      assert_equal '12345678', export_doc_position.customs_tariff_number
      assert_equal '1', export_doc_position.amount
      assert_equal '0.2', export_doc_position.net_weight_in_kg
      assert_equal '24.96', export_doc_position.customs_value

      export_doc_position = export_document.export_doc_positions.last
      assert_equal 'ExportPositionTwo', export_doc_position.description
      assert_equal 'CN', export_doc_position.country_code_origin
      assert_equal '12345678', export_doc_position.customs_tariff_number
      assert_equal '1', export_doc_position.amount
      assert_equal '0.4', export_doc_position.net_weight_in_kg
      assert_equal '99.90', export_doc_position.customs_value

      assert_equal Hash, export_document.to_soap_hash.class
    end


  end
end
