require 'active_record'
# Item Type list
#####################################
get "/item_types" do
  authenticate!
  ActiveRecord::Base.include_root_in_json = false
  viewmodel = ItemTypeListModel.new.load_item_types( params )
  @data = viewmodel.to_json
  haml :'item_type/list/index'
end

get "/item_type" do
  StockApiClient.new.get_item_types( sap_number: params['sap_number'] ).to_json
end

get "/item_type/import" do
  haml :'item_type/import/index'
end

post "/item_type/import" do
  filename = params[:file][:filename]
  tempfile = params[:file][:tempfile]
  target = "public/files/#{filename}"
  overwrite = true if params['overwrite'] == 'on'
  File.open(target, 'wb') {|f| f.write tempfile.read }
  begin
    ItemTypeImportModel.new.import( filename, tempfile, target, overwrite )
    flash[:notice] = 'Products imported'
  rescue
    flash[:notice] = 'Error importing products'
  end
  redirect '/item_types'
end
