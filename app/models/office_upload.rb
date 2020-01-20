class OfficeUpload < ApplicationRecord
  require 'convert_json.rb'

  has_one_attached :source, dependent: :destroy
  has_one_attached :enhanced_json

  def analyze_source_file
    ConvertJson.new(source.download).proceed
  end
end
