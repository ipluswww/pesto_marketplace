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
  def is_in_category(search_category_id)
    if assign_attribute_category.nil?
      return false
    end

    categories = assign_attribute_category.split(',')
    search_category = Category.find_by_id(search_category_id)

    categories.each do |category_id|
      if search_category.own_and_subcategory_ids.include? category_id
        return true
      end
    end

    return false
  end

  def is_in_category_array(search_category_array)
    if search_category_array.nil?
      return false;
    end

    search_category_array.each do |search_category_id|
    
      if is_in_category(search_category_id)
        return true
      end
    end

    return false
  end

  def get_filter_categories
    if filter_category.nil?
      return []
    end

    filter_category.split(',')
  end

  def get_assign_attribute_categories
    if assign_attribute_category.nil?
      return []
    end

    assign_attribute_category.split(',')
  end

  def answer_for(custom_field)
    if custom_field.nil? || custom_field.id.nil? || assign_attribute_options.nil?
      return ''
    end

    # id, value, flag for overwrite,
    options_array = assign_attribute_options.split(',')

    if options_array.length%3 != 0
      return ''
    end

    option_index = 0

    while option_index < options_array.length do

      if options_array[option_index] == custom_field.id.to_s
        return options_array[option_index + 1]
      end

      option_index += 3
    end

    return ''

  end

  def overwrite_answer_for(custom_field)
    if custom_field.nil? || custom_field.id.nil? || assign_attribute_options.nil?
      return ''
    end

    # id, value, flag for overwrite,
    options_array = assign_attribute_options.split(',')

    if options_array.length%3 != 0
      return ''
    end

    option_index = 0

    while option_index < options_array.length do

      if options_array[option_index] == custom_field.id.to_s
        return options_array[option_index + 2] == 'yes'
      end

      option_index += 3
    end

    return ''

  end

  def product_ids
    products = get_queued_products

    product_ids = []
    products.each do |product|
      product_ids += products[:id]
    end

    product_ids = product_ids.join(',')
  end

  def get_queued_products
  	queued_products = []

  	if status == 'disabled'
  	  return queued_products
  	end
  	
  	if performed == 'no'
  	  return queued_products
  	end

    categories = []
    queued_products = Listing

    if !filter_category.nil?
      categories = filter_category.split(',')
    end

    query_where = []

    categories.each do |category_id|
      category = Category.find_by_id(category_id)
      query_where += category.own_and_subcategory_ids
    end

    if !query_where.empty?
      queued_products = Listing.where(:category_id => query_where)
    end

    if !title_contains.nil?
      titles = title_contains.split(',')

      titles.each do |search_word|
        queued_products = queued_products.where("title LIKE ?", "%#{search_word}%")
      end
    end

    if !title_doesnot_contains.nil?
      titles = title_doesnot_contains.split(',')

      titles.each do |search_word|
        queued_products = queued_products.where.not("title LIKE ?", "%#{search_word}%")
      end
    end


    if !description_contains.nil?
      descriptions = description_contains.split(',')

      descriptions.each do |search_word|
        queued_products = queued_products.where("description LIKE ?", "%#{search_word}%")
      end
    end


    if !description_doesnot_contains.nil?
      descriptions = description_doesnot_contains.split(',')

      descriptions.each do |search_word|
        queued_products = queued_products.where.not("description LIKE ?", "%#{search_word}%")
      end
    end

    if (!filter_by_price_from.nil?) && (!filter_by_price_to.nil?)
      queued_products = queued_products.where('price_cents >= ? AND price_cents <= ?', filter_by_price_from, filter_by_price_to)
    end

    if queued_products == Listing
      queued_products = []
    end

    queued_products

  end

end
