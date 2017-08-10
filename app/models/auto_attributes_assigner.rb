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
    if assign_attribute_category.blank?
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
    if search_category_array.blank?
      return false;
    end

    search_category_array.each do |search_category_id|
    
      if is_in_category(search_category_id)
        return true
      end
    end

    return false
  end

  def check_product_is_in_filter(product) 
    products = get_queued_products

    if (products.include? product)
      return true
    end

    return false
  end

  def check_product_id_is_in_filter(product_id) 
    products = get_queued_products

    products.each do |product|
      if (product_id == product[:id])
        return true
      end
    end

    return false
  end

  def get_filter_categories
    if filter_category.blank?
      return []
    end

    filter_category.split(',')
  end

  def get_assign_attribute_categories
    if assign_attribute_category.blank?
      return []
    end

    assign_attribute_category.split(',')
  end

  def get_updated_attribute_options(listing_custom_fields)
    if status == 'disabled'
      return listing_custom_fields
    end
    
    if performed == 'no'
      return listing_custom_fields
    end

    if assign_attribute_options.blank?
      return listing_custom_fields
    end

    # id, value, flag for overwrite,
    options_array = assign_attribute_options.split(',')

    if options_array.length%3 != 0
      return listing_custom_fields
    end

    option_index = 0

    while option_index < options_array.length do
      if options_array[option_index + 1].blank?
        option_index += 3
        next
      end

      flag = false

      listing_custom_fields = listing_custom_fields.map do |field|
        if field[0].to_s == options_array[option_index]
          if options_array[option_index + 2] != 'yes'
            field[1] = options_array[option_index + 1].to_i
          end

          flag = true
        end

        field
      end

      if flag == true
        option_index += 3
        next
      end

      listing_custom_fields = listing_custom_fields + [[options_array[option_index].to_i, options_array[option_index + 1].to_i]]

      option_index += 3
    end

    listing_custom_fields
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
      return false
    end

    # id, value, flag for overwrite,
    options_array = assign_attribute_options.split(',')

    if options_array.length%3 != 0
      return false
    end

    option_index = 0

    while option_index < options_array.length do

      if options_array[option_index] == custom_field.id.to_s
        return options_array[option_index + 2] == 'yes'
      end

      option_index += 3
    end

    return false

  end

  def product_ids
    products = get_queued_products

    product_ids = []
    products.each do |product|
      product_ids += [product[:id]]
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

    if !filter_category.blank?
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

    if !title_contains.blank?
      titles = title_contains.split(',')

      titles.each do |search_word|
        queued_products = queued_products.where("title LIKE ?", "%#{search_word}%")
      end
    end

    if !title_doesnot_contains.blank?
      titles = title_doesnot_contains.split(',')

      titles.each do |search_word|
        queued_products = queued_products.where.not("title LIKE ?", "%#{search_word}%")
      end
    end


    if !description_contains.blank?
      descriptions = description_contains.split(',')

      descriptions.each do |search_word|
        queued_products = queued_products.where("description LIKE ?", "%#{search_word}%")
      end
    end


    if !description_doesnot_contains.blank?
      descriptions = description_doesnot_contains.split(',')

      descriptions.each do |search_word|
        queued_products = queued_products.where.not("description LIKE ?", "%#{search_word}%")
      end
    end

    if (!filter_by_price_from.blank?) && (!filter_by_price_to.blank?)
      queued_products = queued_products.where('price_cents >= ? AND price_cents <= ?', filter_by_price_from, filter_by_price_to)
    end

    if queued_products == Listing
      queued_products = []
    end

    queued_products

  end

end
