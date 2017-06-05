class AddEtsyAttributesToPerson < ActiveRecord::Migration
  def change
    add_column :people, :app_etsy_shop_name, :string
    add_column :people, :app_etsy_api_key, :string
    add_column :people, :app_etsy_api_secret, :string
  end
end
