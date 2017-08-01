class Admin::AutoAttributesAssignersController < Admin::AdminBaseController

  def create
  
  end

  def update

  end

  def index
    @body_class_name         = "admin auto_attributes_assigners"
    @selected_left_navi_link = "listing auto_attributes_assigner"
    
    @auto_attritues_assigners = []

    @auto_attritues_assigners = AutoAttributesAssigner.all
  end

  def new
    @body_class_name         = "admin auto_attributes_assigners_new"
    @selected_left_navi_link = "listing auto_attributes_assigner"
  
  end

  def edit
    @body_class_name         = "admin auto_attributes_assigners_edit"
    @selected_left_navi_link = "listing auto_attributes_assigner"
  
  end

  def show
    @body_class_name         = "admin auto_attributes_assigners_show"
    @selected_left_navi_link = "listing auto_attributes_assigner"
  
  end

  def view_queued_products
    @body_class_name         = "admin auto_attributes_assigners_view_queued_products"
    @selected_left_navi_link = "listing auto_attributes_assigner"
  
    @queued_product_list  = []

    @auto_attritues_assigners = AutoAttributesAssigner.all

    @auto_attritues_assigners.each do |filter|
      products_array =  filter.get_queued_products

      products_array.each do |product| 
        affected_filters = []

        if @queued_product_list[product.id]
          affected_filters = @queued_product_list[product.id][1];
        end

        @queued_product_list[product.id] = [product, affected_filters + [filter.id]]        
      end
    end
  end

end