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
end
