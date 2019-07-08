module Dhl::Bcs::V3
  class BankData

    include Buildable

    PROPERTIES = %i(account_owner bank_name iban note1 note2 bic accountreference).freeze
    attr_accessor(*PROPERTIES)

    def to_soap_hash
      {
        'cis:accountOwner' => account_owner,
        'cis:bank_name' => bank_name,
        'cis:iban' => iban
      }.tap do |h|
        h['cis:note1'] = note1 if note1
        h['cis:note2'] = note2 if note2
        h['cis:bic'] = bic if bic
        h['cis:accountreference'] = accountreference if accountreference
      end
    end

  end
end
