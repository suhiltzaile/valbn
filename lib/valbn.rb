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
    case @country
    when *EU_COUNTRIES
      if defined?(Valvat) == 'constant'
        Valvat.new(@number).exists?(options)
      else
        raise StandardError, 'WARNING: Valvat not found. Please run `gem install valvat`.'
      end
    when 'AU'
      if defined?(Valvat) == 'constant'
        Valabn.new(@number).exists?(options)
      else
        raise StandardError, 'WARNING: Valnzbn not found. Please run `gem install valabn`.'
      end
    when 'NZ'
      if defined?(Valnzbn) == 'constant'
        Valnzbn.new(@number).exists?(options)
      else
        raise StandardError, 'WARNING: Valnzbn not found. Please run `gem install valnzbn`.'
      end
    end
  end
  alias_method :exist?, :exists?
end
