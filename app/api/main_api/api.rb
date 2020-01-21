# frozen_string_literal: true

# This the root path for this whole api
module MainApi
  class Api < Grape::API
    format :json
    prefix 'api'
    version 'v1', using: :path

    desc 'Upload File'
    params do
      requires :source_file, type: File
    end
    post 'file-upload' do
      d_params = declared(params, include_missing: false)
      office_obj = OfficeUpload.create
      file = d_params[:source_file]
      office_obj.source.attach(io: File.open(file[:tempfile]),
       filename: file[:filename], content_type: 'application/csv')
      office_obj.name = office_obj.source.filename.to_s
      office_obj.save!
      office_obj.analyze_source_file
    end

    desc 'get all uploaded record'
    get 'all_records' do
      OfficeUpload.all
    end

    desc 'download uploaded file'
    params do
      requires :id
      requires :type, values: %w[source response rejected], allow_blank: false
    end
    get 'download/:type/:id' do
      d_params = declared(params, include_missing: false)
      file = OfficeUpload.find(d_params[:id]).send(d_params[:type])
      header['Content-Disposition'] = "attachment; filename=#{file.filename.to_s}"
      env['api.format'] = :binary
      file.download
    end
  end
end
