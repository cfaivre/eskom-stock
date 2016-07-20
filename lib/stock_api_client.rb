require 'faraday'
require 'yaml'

class StockApiClient

  def initialize
    env = ENV['RACK_ENV']
    @config = YAML.load_file( File.join(File.dirname(__FILE__), "/../config/stock_api.yml") )[env]
    @connection = JsonService.new( URI.parse(@config['uri']) )
  end

  def get_warehouses
    @connection.get('/api/warehouses', {} )
  end

  def get_cncs
    @connection.get('/api/cncs', {} )
  end

  def get_locations
    @connection.get('/api/locations', {} )
  end

  def get_items( params={} )
    @connection.get('/api/items', params )
  end

  def get_issued_items( params={} )
    @connection.get('/api/items/issued', params )
  end

  def get_non_issued_items( params={} )
    @connection.get('/api/items/non-issued', params )
  end

  def get_items_per_location(params={})
    @connection.get('/api/items-per-location', params )
  end

  def get_item_types( params={} )
    @connection.get('/api/item-types', params )
  end

  def import_item_types( data )
    @connection.post('/api/item-type/import', data.to_json )
  end

  def get_stock_takes(params={} )
    @connection.get('/api/stock-takes', params )
  end

  def item_details( rfids )
    @connection.get('/api/items/detail', {rfids: rfids} )
  end

  def items_update_locations( data )
    @connection.post('/api/items/locations', data.to_json )
  end
end
