class ItemModel

  def initialize(username=nil )
    @username = username
  end

  def details( rfids )
    item_details = StockApiClient.new.item_details( rfids )
    item_details.map{|item|
      { rfid: item[:rfid], location: item[:location],
        purchase_order_number: item[:purchase_order_number],
        manufacture_date: item[:manufacture_date],
        expire_date: item[:expire_date],
        sap_number: item[:sap_number]}
    }
  end

end
