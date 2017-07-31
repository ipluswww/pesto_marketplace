class Admin::AutoAttributesAssignersController < Admin::AdminBaseController

  def create
  
  end

  def update

  end

  def index
    @body_class_name         = "admin auto_attributes_assigner"
    @selected_left_navi_link = "listing auto_attributes_assigner"
  
  end

  def new
    @body_class_name         = "admin auto_attributes_assigner_new"
    @selected_left_navi_link = "listing auto_attributes_assigner"
  
  end

  def edit
    @body_class_name         = "admin auto_attributes_assigner_edit"
    @selected_left_navi_link = "listing auto_attributes_assigner"
  
  end

  def show
    @body_class_name         = "admin auto_attributes_assigner_show"
    @selected_left_navi_link = "listing auto_attributes_assigner"
  
  end

  def view_queued_products
    @body_class_name         = "admin auto_attributes_assigner_view_queued_products"
    @selected_left_navi_link = "listing auto_attributes_assigner"
  
  end

end