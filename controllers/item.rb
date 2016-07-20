require 'active_record'
# Item list
#####################################
get "/items" do
  authenticate!
  ActiveRecord::Base.include_root_in_json = false
  viewmodel = ItemListModel.new.load_items( params )
  @data = viewmodel.to_json
  haml :'item/list/index'
end

get "/items/non-issued" do
  authenticate!
  ActiveRecord::Base.include_root_in_json = false
  viewmodel = ItemListModel.new.load_non_issued_items( params )
  @data = viewmodel.to_json
  @page_header = 'Stock'
  haml :'item/list/index'
end

get "/items/issued" do
  authenticate!
  ActiveRecord::Base.include_root_in_json = false
  viewmodel = ItemListModel.new.load_issued_items( params )
  @data = viewmodel.to_json
  @page_header = 'Issued Stock'
  haml :'item/list/index'
end

# Item Arrivals
#####################################
get "/item/arrival" do
  authenticate!
  #flash[:notice] = "You are signed in as #{session[:user].name}"
  ActiveRecord::Base.include_root_in_json = false
  viewmodel = ItemArrivalModel.new( session[:user].name ).load
  @data = viewmodel.to_json
  haml :'item/arrival/index'
end

# Item Departures
#####################################
get "/item/departure" do
  authenticate!
  ActiveRecord::Base.include_root_in_json = false
  viewmodel = ItemDepartureModel.new( session[:user].name ).load
  @data = viewmodel.to_json
  haml :'item/departure/index'
end

post "/items/locations" ,:provides => :json  do
  authenticate!
  ActiveRecord::Base.include_root_in_json = false
  json = ActiveSupport::JSON.decode request.body.read
  rfids = json['items'].map{ |item| item['rfid'] }
  new_location = json['new_location']
  new_storage_location = json['new_storage_location']
  data = { rfids: rfids, new_location: new_location, new_storage_location: new_storage_location }
  viewmodel = ItemArrivalModel.new(session[:user].name).update_locations( data )
  @data = viewmodel.to_json
end

get "/items-per-location" do
  result = StockApiClient.new.get_items_per_location(sap_number: params['sap_number'])
  result.sort_by{ |k| k[:quantity]}
  result.to_json
end

post "/items/in-transit" ,:provides => :json  do
  authenticate!
  ActiveRecord::Base.include_root_in_json = false
  json = ActiveSupport::JSON.decode request.body.read
  rfids = json['items'].map{ |item| item['rfid'] }
  new_location = 'in-transit'
  new_storage_location = json['new_storage_location']
  data = { rfids: rfids, new_location: new_location, new_storage_location: new_storage_location }
  viewmodel = ItemArrivalModel.new.update_locations( data )
  @data = viewmodel.to_json
end

post "/item/read_arrived_items", :provides => :json do
  authenticate!
  ActiveRecord::Base.include_root_in_json = false
  already_read_rfids = ActiveSupport::JSON.decode request.body.read
  viewmodel = ItemArrivalModel.new.read_arrived_items( already_read_rfids )
  @data = viewmodel.to_json
end

post "/item/read_departure_items", :provides => :json do
  authenticate!
  ActiveRecord::Base.include_root_in_json = false
  already_read_rfids = ActiveSupport::JSON.decode request.body.read
  viewmodel = ItemDepartureModel.new.read_departure_items( already_read_rfids )
  @data = viewmodel.to_json
end

post "/items/details", :provides => :json do
  authenticate!
  ActiveRecord::Base.include_root_in_json = false
  rfids = ActiveSupport::JSON.decode request.body.read
  ItemModel.new.details( rfids ).to_json
end

get "/item/import" do
  haml :'item/import/index'
end

post "/item/import" do
  filename = params[:file][:filename]
  tempfile = params[:file][:tempfile]
  target = "public/files/#{filename}"
  overwrite = true if params['overwrite'] == 'on'
  File.open(target, 'wb') {|f| f.write tempfile.read }
  begin
    ItemImportModel.new.import( filename, tempfile, target, overwrite )
    flash[:notice] = 'Products imported'
  rescue
    flash[:notice] = 'Error importing products'
  end
  redirect '/items'
end
