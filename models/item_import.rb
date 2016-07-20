require 'csv'
require 'roo'

class ItemImportModel

  def initialize(user_id=nil )
    @user_id = user_id
  end

  def import( filename, tempfile, target, overwrite )
    items = []
    spreadsheet = open_spreadsheet(target)
    spreadsheet.each do |row|
      next if row.first.match(/RFID/)
      items << { rfid: row[0],
                 sap_number: row[1],
                 location: row[2],
                 purchase_order_number: row[3],
                 supplier: row[4],
                 expire_date: row[5],
                 manufacture_date: row[6] }
    end
    StockApiClient.new.import_items( items: items, overwrite: overwrite )
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
