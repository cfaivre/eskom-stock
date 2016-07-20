require 'csv'
require 'roo'

class ItemTypeImportModel

  def initialize(user_id=nil )
    @user_id = user_id
  end

  def import( filename, tempfile, target, overwrite )
    item_types = []
    spreadsheet = open_spreadsheet(target)
    spreadsheet.each do |row|
      next if row.first.match(/SAP/)
      item_types << { sap_number: row[0],
                      material_type: row[1],
                      description: row[2],
                      image: row[3] }
    end
    StockApiClient.new.import_item_types( item_types: item_types, overwrite: overwrite )
  end

  def open_spreadsheet(file)
    case File.extname(file)
    when ".csv" then  Roo::CSV.new(file, csv_options: {col_sep: ";"})
    when ".xls" then Excel.new(file, nil, :ignore)
    when ".xlsx" then Excelx.new(file, nil, :ignore)
    else raise "Unknown file type: #{file}"
    end
  end

end
