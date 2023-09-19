# frozen_string_literal: true

class Api::V1::ItemsController < ApplicationController
  before_action :set_item, only: [:update, :show]
  before_action :find_item, only: :find_item
  def index
    items = Item.preload(:inventory_level, :category).search(params[:search])
    items = items.paginate(page: params[:page], per_page: params[:per_page])
    render json: { items: ItemsRepresenter.new(items).as_json, total: items.total_entries }
  end

  def show
    render json: ItemRepresenter.new(@item).as_json
  end

  def find_item
    @item = Item.find_by_barcode!(params[:barcode])
    render json: ItemRepresenter.new(@item).as_json
  end

  def create
    category = Category.find(item_params[:category_id])
    item = category.items.create(item_params.merge(barcode: Item.generate_barcode(item_params[:name], item_params[:color], item_params[:size]), selling_price: item_params[:price].to_f + LineItem.calculate_vat(item_params[:price].to_f, 1)))
    if item.persisted?
      render json: ItemRepresenter.new(item).as_json, status: :created
    else
      render json: item.errors.full_messages, status: :unprocessable_entity
    end
  end

  def update
    if @item.update(item_params.merge(selling_price: item_params[:price].to_f + LineItem.calculate_vat(item_params[:price].to_f, 1)))
      render json: ItemRepresenter.new(@item).as_json, status: :ok
    else
      render json: @item.errors.full_messages, status: :unprocessable_entity
    end
  end

  def destroy
    Item.find(params[:id]).destroy!
    head :no_content
  end

  private

  def item_params
    params.require(:item).permit(:name, :price, :size, :color, :category_id)
  end

  def set_item
    category = Category.find(params[:category_id])
    @item = category.items.find(params[:id])
  end
end
