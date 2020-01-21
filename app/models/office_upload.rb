class OfficeUpload < ApplicationRecord
  require 'convert_json.rb'

  has_one_attached :source
  has_one_attached :response
  has_one_attached :rejected

  def analyze_source_file
    result = ConvertJson.new(source.download).proceed
    paths = []
    { final_obj: 'response', rejected_obj: 'rejected' }.each do |type, name|
      file_name = "#{id}_#{name}.json"
      path = "public/tmp/#{file_name}"
      File.open(path,"w") do |f|
        f.write(result[type].to_json)
      end
      send(name).attach(io: File.open(path),
       filename: file_name, content_type: 'application/json')
       paths << path
    end
  end
end
