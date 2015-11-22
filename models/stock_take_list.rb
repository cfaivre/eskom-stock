class StockTakeListModel

  def initialize(user_id=nil )
    @user_id = user_id
  end

  def load_stock_takes
    viewmodel = StockTakeListViewModel.new
    stock_takes = StockApiClient.new.get_stock_takes
    stock_takes.sort_by! { |stock_take| stock_take[:created_at] }.reverse! unless stock_takes.empty?
    stock_takes.each{|stock_take|
      if !File.exist?( File.join(File.dirname(__FILE__), "/../public/pdfs/#{stock_take[:_id]}.pdf") )
        generate_pdf( stock_take[:_id], stock_take[:created_at], stock_take[:stats] )
      end
      stock_take[:created_at] = Time.parse(stock_take[:created_at]).strftime('%Y/%m/%d %H:%M')
      # Sort stats by biggest count to smallest
      new_stats = stock_take[:stats].sort_by(&:last).reverse.to_h
      stock_take[:stats] = new_stats
    }
    viewmodel.stock_takes = stock_takes
    viewmodel
  end

  def generate_pdf( id, date, data )
    require "prawn/table"
    pdf = Prawn::Document.new
    pdf.text( "Stock Level Report: #{Time.parse( date.to_s ).strftime('%Y/%m/%d %H:%M')}" )
    contents = [ [ { content: 'Material number'},
                   { content: 'Description'},
                   { content: 'Quantity'} ] ]
    data.each do |k, v|
      item_type = StockApiClient.new.get_item_types(sap_number: k).first
      contents +=  [ [ { content: k.to_s},
                       { content: item_type[:description].to_s},
                       { content: v.to_s } ] ]
    end
    pdf.table( contents )
    pdf.render_file File.join(File.dirname(__FILE__), "/../public/pdfs/#{id}.pdf")
  end

end
