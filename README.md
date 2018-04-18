# Dhl::Bcs

This is a client for the DHL Business Customer Shipping (BCS) API version 2.0.
It is inspired by the [DHL intraship gem](https://github.com/waldher/dhl-intraship) which implements API version 1.0 which is expired.
The Dhl::Bcs gem uses [Savon 2](https://github.com/savonrb/savon) to communicate via SOAP with the DHL API.
The DHL BCS API is just for standard parcels. If you are looking for shipping of express parcels this gem is not for you.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dhl-bcs'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dhl-bcs

## Usage

Initialize a new API client using

```ruby
client = Dhl::Bcs.client(config, options)
```

Config is the following hash:

```ruby
config = {
  api_user: 'The user for API BasicAuth', #mandatory
  api_pwd: 'The password for API BasicAuth', #mandatory
  user: 'your BCS user name', #mandatory
  signature: 'Your BCS user password', #mandatory
  ekp: 'Your DHL EKP (first part of your DHL Account number)', #mandatory
  participation_number: 'Your DHL participation_number (last two characters of your DHL Account number)' #mandatory
}
```

Options is an optional parameter and can contain the following parameters:

```ruby
options = {
 test: true, # If test is set, all API calls go against the DHL test system (defaults to false)
 log: false # If log is set, you get all logging (with request and response XML) to your standard logger. (defaults to true)
}
```

### Where do I get all these numbers?
If you are confused about all the number and credential stuff here is a short explanation.

DHL uses a customer integration gateway (cig) for its services.
You have to register your app first at the developer portal of dhl, define an app_id and get a token for that.
`api_user` is your app_id and `api_pwd` is the token you get.
This is basically needed to communicate with the DHL services.

To identify as a BCS user you have to give your credentials of the BCS website as `user` and `signature`.

The billing works with a number (Abrechnungsnummer) with 14 chars that consists of three parts.
The first 10 digits are your EKP (Einheitliche Kunden- und Produktnummer) that you get from your DHL contract.

The next 2 digits are product dependent (Verfahren), so you don't have to specify it, because they are known if you specify a product at the shipment.

The last 2 chars, the participation_number (Teilnahme-Nummer) can be digits or uppercase characters.
This is contract dependent and used to specify billing conditions.


### Create shipments

To create a shipment at DHL you need a sender_address, a receiver_address, and informations about the parcel.

```ruby
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
    name: 'Jane Doe',
    street_name: 'Willy-Brandt-Straße',
    street_number: '1',
    zip: '10557',
    city: 'Berlin',
    country_code: 'DE',
    email: 'jane.doe@example.com'
  },
  weight: 3.5,
  length: 10,
  width: 20,
  height: 30,
  shipment_date: Date.new(2016, 7, 13)
)

client.create_shipment_order(shipment)
```

You will get a result that looks like this:

```ruby
[
  {
    status: { status_code: '0', status_text: 'ok', status_message: 'Der Webservice wurde ohne Fehler ausgeführt.' },
    shipment_number: '22222222201019582121',
    label_url: 'https://cig.dhl.de/gkvlabel/SANDBOX/dhl-vls/gw/shpmntws/printShipment?token=JD7HKktuvugIFEkhSvCfbEz4J8Ah0dkcVuw4PzBGRyRnW%2FwEPAwfytLtb31e7gMDsSX32%2BEB5exp8nNPs%2FhJSQ%3D%3D',
  }
]
```

This is an Array of Hashes, cause it is possible to send up to 30 parcels at the same time, with the API.
Say you want to send 3 parcels to the same address you can also do something like that:

```ruby
shipper = Dhl::Bcs.build_shipper(
  name: 'Christoph Wagner',
  company: 'webit! Gesellschaft für neue Medien mbH',
  street_name: 'Schandauer Straße',
  street_number: '34',
  zip: '01309',
  city: 'Dresden',
  country_code: 'DE',
  email: 'wagner@webit.de'
)

receiver = Dhl::Bcs.build_receiver(
  name: 'Jane Doe',
  street_name: 'Willy-Brandt-Straße',
  street_number: '1',
  zip: '10557',
  city: 'Berlin',
  country_code: 'DE',
  email: 'jane.doe@example.com'
)

shipment1 = Dhl::Bcs.build_shipment(shipper: shipper, receiver: receiver, weight: 3)
shipment2 = Dhl::Bcs.build_shipment(shipper: shipper, receiver: receiver, weight: 3.5)
shipment3 = Dhl::Bcs.build_shipment(shipper: shipper, receiver: receiver, weight: 4)

client.create_shipment_order(shipment1, shipment2, shipment3)
```
### International Shipments

In order to send parcels outside of the EU, one should provide information about the content of the shipment.   
Dhl offers cn23 document, which is data for the Customs as this kind of shipment is considered Export of goods.
As an output one gets, in addition to the label, a url for the document in an A4-format ready to be printed.

The way to implement that is identical of shipper's and receiver's ones.

```ruby
export_document = {
  invoice_number = 'ABCDEF...',
  export_type = 'Document',  #  could be one of these ['RETURN_OF_GOODS','PRESENT','COMMERCIAL_SAMPLE','DOCUMENT','OTHER']
  export_type_description = 'some desc', # should be set if `export_type` was set to 'OTHER'
  terms_of_trade = 'DDP', # could be one of these ['DDP','DXV','DDU','DDX']
  place_of_commital= 'Bern',
  permit_number = 1232135,
  attestation_number = 1234345,
  with_electronic_export_notification = true, # true|false
  export_doc_positions: [
    {
      description: 'content1',
      country_code_origing: 'CN',
      customs_tariff_number: '1234567',
      ammount: 1,
      net_weight_in_kg: 0.2,
      customs_value: 25.00
    },
    {
      description: 'content2',
      country_code_origing: 'DE',
      customs_tariff_number: '00222011',
      ammount: 1,
      net_weight_in_kg: 1.2,
      customs_value: 112.00
    }
  ]
}

shipment = Dhl::Bcs.build_shipment(export_document: export_document, shipper: shipper, receiver: receiver)
```

and then one gets a result like this:

```ruby
[
  {
    status: { status_code: '0', status_text: 'ok', status_message: 'Der Webservice wurde ohne Fehler ausgeführt.' },
    shipment_number: '22222222201019582121',
    label_url: 'https://cig.dhl.de/gkvlabel/SANDBOX/dhl-vls/gw/shpmntws/printShipment?token=JD7HKktuvugIFEkhSvCfbEz4J8Ah0dkcVuw4PzBGRyRnW%2FwEPAwfytLtb31e7gMDsSX32%2BEB5exp8nNPs%2FhJSQ%3D%3D',
    export_label_url: 'https://cig.dhl.de/gkvlabel/SANDBOX/dhl-vls/gw/shpmntws/printShipment?token=Vfov%2BMinVhMH6nQVfvSCmNUSRNnaQNHKPaiLiWtXsqm%2BENCM6wnStB2C44rl6BEmSxbrPeaTQwBhoHBr802FnuftGVJ9uVM0C0ztLpxNfyc%3D',
  }
]
```

### Validate shipments

```ruby
client.validate_shipment(shipment1, shipment2, shipment3)
```

### Update shipment

You can update a shipment at DHL. It is the same like deleting it and creating a new one just with one request.
So you will get a new shipping number for it and so on.
To update a shipment you need the shipment number of the old one and give a complete new shipment that is created instead.
This works for one shipment at a time.
```ruby
client.update_shipment_order('22222222901010000944', shipment)
```

### Other methods

The methods `delete_shipment_order`, `get_label`, `get_export_doc` and `do_manifest` works technically the same.
They took one or many (up to 30) shipment numbers and do something with these shipments at DHL.

To delete a shipment you can use:
```ruby
client.delete_shipment_order('22222222901010000944')
```

As result you will get one Hash like:
```ruby
{
  '22222222901010000944' => {
    status: { status_code: '0', status_text: 'ok', status_message: nil }
  }
}
```    

### Services

There is a basic support to add Services to a shipment in this gem.

```ruby
shipment.services << Dhl::Bcs.build_service(name: 'IndividualSenderRequirement', attributes: { active: '1', details: 'Test' })
```

A service has a name and attributes.
Sometimes a service has children, for example the 'IdentCheck'-Service.

```ruby
shipment.services << Dhl::Bcs.build_service(name: 'IdentCheck', attributes: { active: '1' }, children: { 'Ident' => { surname: 'Doe', given_name: 'Jon Doe', date_of_birth: '1980-12-24', minimum_age: '18' } })
```

Check out the DHL developer documentation to configure the services you need.

### Get API version

```ruby
client.get_version
```
You don't need a shipment for that.

### Logging

If you need the last made request and its response from the client you can use:
```ruby
client.last_log
```
This works even if you used the option `log: false` at the client. This option controlls just the output in the log file or console.

### Everything else
Have a deeper look at the code of this gem and find out how things work.
You can help to implement missing things or extend this documentation.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/webit-de/dhl-bcs. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
