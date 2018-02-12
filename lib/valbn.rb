require "valbn/version"
require 'countries'

class Valbn

  EU_COUNTRIES = ISO3166::Country.find_all_countries_by_in_eu?(true).map(&:alpha2)

  def self.vatmoss=(value)
    @@vatmoss = value # Valvat
    value ? require('valvat') : false
  rescue
    raise StandardError, 'WARNING: Valvat not found. Please run `gem install valvat`.'
  end

  def self.abn=(value)
    @@abn = value # Valabn
    value ? require('valabn') : false
  rescue
    raise StandardError, 'WARNING: Valnzbn not found. Please run `gem install valabn`.'
  end

  def self.nzbn=(value)
    @@abn = value # Valnzbn
    value ? require('valnzbn') : false
  rescue
    raise StandardError, 'WARNING: Valnzbn not found. Please run `gem install valnzbn`.'
  end

  def self.configure
    yield self
  end

  def initialize(number, country)
    @country = country
    number = number.to_s.gsub(/\W/, '').upcase

    if EU_COUNTRIES.include?(country)
      vat_country = Valvat::Utils.iso_country_to_vat_country(country)
      number = "#{vat_country}#{number}" unless !!(number =~ /^#{vat_country}[A-Z0-9]+/) # add the country code if it does not exist
    end

    @number = number
  end

  def exists?(options = {})
    options[:detail] = options[:formatted]

    case @country
    when *EU_COUNTRIES
      if defined?(Valvat) == 'constant'
        result = Valvat.new(@number).exists?(options)

        if options[:formatted] == true && !result.nil? && result.is_a?(Hash)
          result = {
            original_format: result,
            name: result[:name],
            street_line_1: result[:address]
          }
        end
      else
        raise StandardError, 'WARNING: Valvat not found. Please run `gem install valvat`.'
      end
    when 'AU'
      if defined?(Valvat) == 'constant'
        result = Valabn.new(@number).exists?(options)

        if options[:formatted] == true && !result.nil? && result.is_a?(Hash)
          begin
            business = result[:search_by_ab_nv201408_response][:abr_payload_search_results][:response][:business_entity201408]
          rescue
            business = {}
          end

          result = {
            original_format: result,
            name: (business[:main_name] || {})[:organisation_name],
            region: (business[:main_business_physical_address] || {})[:state_code],
            postal_code: (business[:main_business_physical_address] || {})[:postcode]
          }
        end
      else
        raise StandardError, 'WARNING: Valnzbn not found. Please run `gem install valabn`.'
      end
    when 'NZ'
      if defined?(Valnzbn) == 'constant'
        result = Valnzbn.new(@number).exists?(options)
        if options[:formatted] == true && !result.nil? && result.is_a?(Hash)
          address = result[:registeredAddress] || [{}]

          result = {
            original_format: result,
            name: result[:entityName],
            street_line_1: address.first[:address1],
            street_line_2: address.first[:address2],
            city: address.first[:address3],
            postal_code: address.first[:postCode]
          }
        end
      else
        raise StandardError, 'WARNING: Valnzbn not found. Please run `gem install valnzbn`.'
      end
    end

    result
  end
  alias_method :exist?, :exists?

  def iso_country_code
    case @country
    when *EU_COUNTRIES
      Valvat.new(@number).iso_country_code
    else
      @country
    end
  end
end
