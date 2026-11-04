class StockOrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stock_order, only: [ :show, :edit, :update, :destroy ]

  def index
    @stock_orders = StockOrder.accessible_by(current_user)
                              .where.not(status: [ :rejected, :completed ])
                              .includes(:user, :school, :stock_sub_items)
    apply_filters_and_group
  end

  def pending
    @stock_orders = StockOrder.accessible_by(current_user)
                              .where(status: [ :pending, :in_delivery ])
                              .includes(:user, :school, :stock_sub_items)
    apply_filters_and_group
  end

  def completed
    @stock_orders = StockOrder.accessible_by(current_user)
                              .where(status: [ :rejected, :completed ])
                              .includes(:user, :school, :stock_sub_items)
    apply_filters_and_group
    render :index
  end

  def show
  end

  def new
    @stock_order = StockOrder.new
    load_form_collections

    @schools_in_delivery = StockOrder.accessible_by(current_user)
                                     .where(status: :in_delivery)
                                     .pluck(:school_id, :id.to_s)
  end

  def create
    @stock_order = current_user.stock_orders.build(stock_order_params)

    if @stock_order.save
      redirect_to stock_orders_path, notice: "Stock order was successfully created."
    else
      load_form_collections
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    load_form_collections
  end

  def update
    if @stock_order.update(stock_order_params)
      respond_to do |format|
        format.html { redirect_to @stock_order, notice: "Stock order was successfully updated." }
        format.json { render json: { status: :ok, message: "Order updated successfully." } }
      end
    else
      respond_to do |format|
        format.html { load_form_collections; render :show, status: :unprocessable_entity }
        format.json { render json: @stock_order.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @stock_order.destroy
    redirect_to stock_orders_path, notice: "Stock order was successfully deleted."
  end

  private

  def set_stock_order
    @stock_order = StockOrder.accessible_by(current_user).find(params[:id])
  end

  def apply_filters_and_group
    # Search query filtering
    if params[:query].present?
      @stock_orders = @stock_orders.left_joins(:company).where("companies.name LIKE ? OR stock_orders.purpose LIKE ?", "%#{params[:query]}%", "%#{params[:query]}%")
    end

    # Status filter
    if params[:status].present?
      @stock_orders = @stock_orders.where(status: params[:status])
    end

    # School & State filter
    if params[:school_id].present?
      @stock_orders = @stock_orders.where(school_id: params[:school_id])
    elsif params[:state].present?
      school_ids_in_state = User.school.where(state: params[:state]).select(:id)
      @stock_orders = @stock_orders.where(school_id: school_ids_in_state)
    end

    # Date Range filter
    if params[:start_date].present?
      @stock_orders = @stock_orders.where("created_at >= ?", params[:start_date].to_date.beginning_of_day)
    end
    if params[:end_date].present?
      @stock_orders = @stock_orders.where("created_at <= ?", params[:end_date].to_date.end_of_day)
    end

    # Dropdown collections for filters
    orders_scope = current_user.admin? ? StockOrder.all : StockOrder.accessible_by(current_user)
    @schools = User.school.where(id: orders_scope.select(:school_id))

    @states_data = User.states.keys.map do |state_key|
      state_schools = @schools.where(state: state_key)

      state_schools_data = state_schools.map do |school|
        school_orders = @stock_orders.where(school_id: school.id).order(created_at: :desc)
        { school: school, stock_orders: school_orders } if school_orders.any?
      end.compact

      { state: state_key, schools: state_schools_data } if state_schools_data.any?
    end.compact
  end

  def load_form_collections
    @schools = if current_user.admin?
      User.school
    elsif current_user.school?
      [ current_user ]
    else
      current_user.assigned_schools.presence || User.school
    end

    @stock_items = StockItem.includes(:stock_sub_items).all
    @managers = User.where(manager: true)
    @contractors = User.where(role: :contractor)
    @companies = Company.order(:name)
  end

  def stock_order_params
    params.require(:stock_order).permit(
      :school_id,
      :company_id,
      :purpose,
      :teacher_phone_number,
      :teacher_email,
      :approver_1_id,
      :approver_2_id,
      :contractor_id,
      :order_proof,
      :status,
      stock_order_items_attributes: [ :id, :stock_sub_item_id, :quantity, :_destroy ]
    )
  end
end
