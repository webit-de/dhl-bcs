require 'savon'
require 'stringio'
require 'logger'

module Dhl::Bcs::V2
  class Client

    WSDL = 'https://cig.dhl.de/cig-wsdls/com/dpdhl/wsdl/geschaeftskundenversand-api/2.0/geschaeftskundenversand-api-2.0.wsdl'

    def initialize(config, log: true, test: false, **options)
      raise "User must be specified" if config[:user].nil?
      raise "Signature (password) must be specified" if config[:signature].nil?
      raise "EKP (first part of the DHL account number) must be specified" if config[:ekp].nil?
      raise "Participation Number (last two characters of account number) must be specified" if config[:participation_number].nil?
      raise "Api User must be specified" if config[:api_user].nil?
      raise "Api Password must be specified" if config[:api_pwd].nil?

      @ekp = config[:ekp]
      @participation_number = config[:participation_number]

      @logIO = StringIO.new
      @logger = log && Logger.new($stdout)

      @client = Savon.client({
        endpoint: (test ? 'https://cig.dhl.de/services/sandbox/soap' : 'https://cig.dhl.de/services/production/soap'),
        wsdl: WSDL,
        basic_auth: [config[:api_user], config[:api_pwd]],
        logger: Logger.new(@logIO),
        log: true,
        soap_header: {
          'cis:Authentification' => {
            'cis:user' => config[:user],
            'cis:signature' => config[:signature],
            'cis:type' => 0
          }
        },
        namespaces: { 'xmlns:cis' => 'http://dhl.de/webservice/cisbase' }
      })
    end

    def get_version(major: 2, minor: 0, build: nil)
      request(:get_version,
        'bcs:Version' => {
          'majorRelease' => major,
          'minorRelease' => minor
        }.tap { |h| h['build'] = build if build }
      ) do |response|
        response.body[:get_version_response][:version]
      end
    end

    def validate_shipment(*shipments, **options)
      request(:validate_shipment, build_shipment_orders(shipments, options)) do |response|
        [response.body[:validate_shipment_response][:validation_state]].flatten.map do |validation_state|
          validation_state[:status]
        end
      end
    end

    def create_shipment_order(*shipments, **options)
      request(:create_shipment_order, build_shipment_orders(shipments, options)) do |response|
        [response.body[:create_shipment_order_response][:creation_state]].flatten.map do |creation_state|
          creation_state[:label_data]
        end
      end
    end

    def update_shipment_order(shipment_number, shipment, **options)
      request(:update_shipment_order, { 'cis:shipmentNumber' => shipment_number }.merge(build_shipment_orders([shipment], options))) do |response|
        clean_response_data(response.body[:update_shipment_order_response][:label_data])
      end
    end

    {
      delete_shipment_order: :deletion_state,
      get_label: :label_data,
      get_export_doc: :export_doc_data,
      do_manifest: :manifest_state
    }.each do |api_method, response_key|
      define_method api_method do |*shipment_numbers|
        raise Dhl::Bcs::DataError, 'No more than 30 shipment_numbers allowed per request!' if shipment_numbers.size > 30
        request(api_method, 'cis:shipmentNumber' => shipment_numbers) do |response|
          h = {}
          [response.body[:"#{api_method}_response"][response_key]].flatten.each do |data|
            h[data.delete(:shipment_number)] = clean_response_data(data)
          end
          h
        end
      end
    end

    # returns base64 encoded PDF Dokument
    def get_manifest(date)
      request(:get_manifest, 'manifestDate' => date) do |response|
        response.body[:get_manifest_response][:manifest_data]
      end
    end

    def last_log
      @logIO.string
    end

    protected

    def build_shipment_orders(shipments, label_response_type: 'URL')
      raise Dhl::Bcs::DataError, 'No more than 30 shipments allowed per request!' if shipments.size > 30
      {
        'ShipmentOrder' =>
          shipments.map.with_index(1) do |shipment, index|
            {
              'sequenceNumber' => format('%02i', index.to_s),
              'Shipment' => shipment.to_soap_hash(@ekp, @participation_number),
              'LabelResponseType' => label_response_type.to_s.upcase
            }
          end
      }
    end

    def request(action, message = {})
      @logIO.string = ''
      response = @client.call(action, message: {
        'bcs:Version' => {
          'majorRelease' => 2,
          'minorRelease' => 0
        }
      }.merge(message))
      @logger << @logIO.string if @logger
      yield response
    rescue
      raise Dhl::Bcs::RequestError, @logIO.string
    end

    def clean_response_data(data)
      data.delete(:@xmlns)
      data
    end

  end
end
