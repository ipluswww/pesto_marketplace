class Admin::AutoAttributesAssignersController < Admin::AdminBaseController

  def create
    @new_assigner = AutoAttributesAssigner.new
    @new_assigner[:status]                        = params[:auto_attributes_assigner][:status]
    @new_assigner[:priority]                      = params[:auto_attributes_assigner][:priority]
    @new_assigner[:title_contains]                = params[:auto_attributes_assigner][:title_contains]
    @new_assigner[:title_doesnot_contains]        = params[:auto_attributes_assigner][:title_doesnot_contains]
    @new_assigner[:description_contains]          = params[:auto_attributes_assigner][:description_contains]
    @new_assigner[:description_doesnot_contains]  = params[:auto_attributes_assigner][:description_doesnot_contains]
    @new_assigner[:filter_by_price_from]          = params[:auto_attributes_assigner][:filter_by_price_from]
    @new_assigner[:filter_by_price_to]            = params[:auto_attributes_assigner][:filter_by_price_to]

    if !params[:filter_category].nil?
      @new_assigner[:filter_category]            = params[:filter_category].join(',')
    end

    if !params[:assign_attribute_category].nil?
      @new_assigner[:assign_attribute_category]  = params[:assign_attribute_category].join(',')
    end

    assign_attribute_options = []

    if !params[:custom_fields].nil?
      params[:custom_fields].each do |key, value|

        if params[:overwrite_property].nil? || params[:overwrite_property][key].nil?
          assign_attribute_options += [key, value, 'no']
        else
          assign_attribute_options += [key, value, 'yes']
        end
      end
    end
    
    @new_assigner[:assign_attribute_options] = assign_attribute_options.join(',')

    @new_assigner.save

    flash[:notice] = 'Successfully Created!'
    redirect_to :action => :new
  end

  def update
    @new_assigner = @auto_attributes_assigner = AutoAttributesAssigner.find(params[:id])

    @new_assigner[:status]                        = params[:auto_attributes_assigner][:status]
    @new_assigner[:priority]                      = params[:auto_attributes_assigner][:priority]
    @new_assigner[:title_contains]                = params[:auto_attributes_assigner][:title_contains]
    @new_assigner[:title_doesnot_contains]        = params[:auto_attributes_assigner][:title_doesnot_contains]
    @new_assigner[:description_contains]          = params[:auto_attributes_assigner][:description_contains]
    @new_assigner[:description_doesnot_contains]  = params[:auto_attributes_assigner][:description_doesnot_contains]
    @new_assigner[:filter_by_price_from]          = params[:auto_attributes_assigner][:filter_by_price_from]
    @new_assigner[:filter_by_price_to]            = params[:auto_attributes_assigner][:filter_by_price_to]

    if !params[:filter_category].nil?
      @new_assigner[:filter_category]            = params[:filter_category].join(',')
    end

    if !params[:assign_attribute_category].nil?
      @new_assigner[:assign_attribute_category]  = params[:assign_attribute_category].join(',')
    end

    assign_attribute_options = []

    if !params[:custom_fields].nil?
      params[:custom_fields].each do |key, value|

        if params[:overwrite_property].nil? || params[:overwrite_property][key].nil?
          assign_attribute_options += [key, value, 'no']
        else
          assign_attribute_options += [key, value, 'yes']
        end
      end
    end
    
    @new_assigner[:assign_attribute_options] = assign_attribute_options.join(',')

    @new_assigner.save

    flash[:notice] = 'Successfully Saved!'
    redirect_to :action => :index
  end

  def index
    @body_class_name         = "admin auto_attributes_assigners"
    @selected_left_navi_link = "auto_attributes_assigner"
    
    @auto_attritues_assigners = []

    @auto_attritues_assigners = AutoAttributesAssigner.all
  end

  def new
    @body_class_name         = "admin auto_attributes_assigners_new"
    @selected_left_navi_link = "auto_attributes_assigner"

    @auto_attributes_assigner = AutoAttributesAssigner.new
    @custom_field_questions   = CustomField.all

    @filter_category           = @auto_attributes_assigner.get_filter_categories
    @assign_attribute_category = @auto_attributes_assigner.get_assign_attribute_categories
  
  end

  def edit
    @body_class_name         = "admin auto_attributes_assigners_edit"
    @selected_left_navi_link = "auto_attributes_assigner"
    
    @auto_attributes_assigner = AutoAttributesAssigner.find(params[:id])
    @custom_field_questions   = CustomField.all

    @filter_category           = @auto_attributes_assigner.get_filter_categories
    @assign_attribute_category = @auto_attributes_assigner.get_assign_attribute_categories
  
  end

  def show
    @body_class_name         = "admin auto_attributes_assigners_show"
    @selected_left_navi_link = "auto_attributes_assigner"
  
  end

  def view_queued_products
    @body_class_name         = "admin auto_attributes_assigners_view_queued_products"
    @selected_left_navi_link = "auto_attributes_assigner"
  
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