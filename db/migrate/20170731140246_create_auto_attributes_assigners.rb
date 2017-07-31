class CreateAutoAttributesAssigners < ActiveRecord::Migration
  def change
    create_table :auto_attributes_assigners do |t|
      t.string :status
      t.string :performed
      t.integer :priority
      t.text :filtered_product_ids
      t.string :title_contains
      t.string :title_doesnot_contains
      t.string :description_contains
      t.string :description_doesnot_contains
      t.text :filter_category
      t.string :supplier_attributes_contains
      t.string :supplier_attributes_doesnot_contains
      t.string :supplier_category_contains
      t.string :supplier_category_doesnot_contains
      t.string :filter_by_price_from
      t.string :filter_by_price_to
      t.string :filter_by_cost_price_from
      t.string :filter_by_cost_price_to
      t.text :filter_by_seller
      t.text :assign_attribute_options
      t.text :assign_attribute_category

      t.timestamps null: false
    end
  end
end
