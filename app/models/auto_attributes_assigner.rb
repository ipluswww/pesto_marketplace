# == Schema Information
#
# Table name: auto_attributes_assigners
#
#  id                                   :integer          not null, primary key
#  status                               :string(255)
#  performed                            :string(255)
#  priority                             :integer
#  filtered_product_ids                 :text(65535)
#  title_contains                       :string(255)
#  title_doesnot_contains               :string(255)
#  description_contains                 :string(255)
#  description_doesnot_contains         :string(255)
#  filter_category                      :text(65535)
#  supplier_attributes_contains         :string(255)
#  supplier_attributes_doesnot_contains :string(255)
#  supplier_category_contains           :string(255)
#  supplier_category_doesnot_contains   :string(255)
#  filter_by_price_from                 :string(255)
#  filter_by_price_to                   :string(255)
#  filter_by_cost_price_from            :string(255)
#  filter_by_cost_price_to              :string(255)
#  filter_by_seller                     :text(65535)
#  assign_attribute_options             :text(65535)
#  assign_attribute_category            :text(65535)
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#

class AutoAttributesAssigner < ActiveRecord::Base

  def get_queued_products
  	queued_products = []

  	if status == 'disabled'
  	  return queued_products
  	end
  	
  	if performed == 'no'
  	  return queued_products
  	end

    categories = filter_category.split(',')

    query_where = []

    categories.each do |category_id|
      category = Category.find_by_id(category_id)
      query_where += category.own_and_subcategory_ids
    end

    if (!query_where.empty?)
      queued_products = Listing.where(:category_id => query_where)
    end

    if (!title_contains.nil?)
      titles = title_contains.split(',')

      titles.each do |search_word|
        queued_products = Listing.where("title LIKE ?", "%#{search_word}%")
      end
    end

    if (!title_doesnot_contains.nil?)
      titles = title_doesnot_contains.split(',')

      titles.each do |search_word|
        queued_products = Listing.where.not("title LIKE ?", "%#{search_word}%")
      end
    end


    if (!description_contains.nil?)
      descriptions = description_contains.split(',')

      descriptions.each do |search_word|
        queued_products = Listing.where("description LIKE ?", "%#{search_word}%")
      end
    end


    if (!description_doesnot_contains.nil?)
      descriptions = description_doesnot_contains.split(',')

      descriptions.each do |search_word|
        queued_products = Listing.where.not("description LIKE ?", "%#{search_word}%")
      end
    end

    if (!filter_by_price_from.nil?) && (!filter_by_price_to.nil?)
      queued_products = Listing.where('price_cents >= ? AND price_cents <= ?', filter_by_price_from, filter_by_price_to)
    end

    queued_products

  end
end
