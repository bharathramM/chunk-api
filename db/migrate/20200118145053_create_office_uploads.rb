class CreateOfficeUploads < ActiveRecord::Migration[6.0]
  def change
    create_table :office_uploads, id: :uuid do |t|
      t.string :name
      t.timestamps
    end
  end
end
