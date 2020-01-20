
  class ConvertJson
    require 'csv.rb'
    attr_accessor :csv_data

    def initialize(csv_data)
      self.csv_data = csv_data
    end

    def proceed
      csv_obj = CSV.parse(csv_data)
      keys = csv_obj.first.map {|key| key.strip}
      result = {}
      error_obj = []
      csv_obj[1..(csv_obj.length - 1)].each do |person|
        record = keys.clone
        person.each_with_index do |value, index|
          record[index] = [record[index], value]
        end
        record = record.to_h
        begin
          create_or_update(result, record, record['License number'])
        rescue => e
          error_obj << record
        end
      end
      { final_obj: result.values, rejected_obj: error_obj }
    end

    def create_or_update(source, object, key)
      raise 'License number should not be empty' if key.blank?

      existing_obj = source[key]
      date_col = 'Last update date'
      return source[key] = object unless existing_obj

      if validate_date(existing_obj[date_col], object[date_col])
        source[key] = enhanced_object(object)
      end
    end

    def enhanced_object(object)
      mapping = {
        'License number' => 'validate_license',
        'Phone 1 number' => 'enhance_phone',
        'Phone 2 number' => 'enhance_phone',
        'Phone 3 number' => 'enhance_phone'
      }
      mapping.each do |key, method_name|
        object[key] = send(method_name, object[key])
      end
      object
    end

    def validate_license(license)
      if license.length != 10 && (license[0..8].reduce(:+) % 10 != license[9])
        raise 'Invalid License number'
      end
      license
    end

    def enhance_phone(date)
      date = date.scan(%r(\d))
      return unless date.length >= 10

      "(#{date[0..2].join('')}) #{date[3..5].join('')}-#{date[6..9].join('')}"
    end

    def validate_date(existing, source)
      return true if existing.blank?

      return false if source.blank?

      Date.strptime(source, '%m/%d/%Y') > Date.strptime(existing, '%m/%d/%Y')
    end
  end
