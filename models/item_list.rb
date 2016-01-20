class ItemListModel

  def initialize(user_id=nil )
    @user_id = user_id
  end

  def load_items( filter )
    viewmodel = ItemListViewModel.new
    items = StockApiClient.new.get_items( filter )
    if !items.empty?
      items.sort_by! { |item| item["name"] } unless items.empty?
      items.each{|item|
        item[:location].gsub!(/\w+/, &:capitalize)
      }
    end
    viewmodel.items = items
    viewmodel
  end

end
