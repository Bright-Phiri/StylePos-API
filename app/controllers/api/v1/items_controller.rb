# frozen_string_literal: true

class Api::V1::ItemsController < ApplicationController
  before_action :set_item, only: [:update, :show, :destroy]
  def index
    items = Item.preload(:inventory_level).search(params[:search])
    items = items.paginate(page: params[:page], per_page: params[:per_page])
    render json: { items: ItemsRepresenter.new(items).as_json, total: items.total_entries }
  end

  def show
    render json: ItemRepresenter.new(@item).as_json
  end

  def create
    item = Item.new(item_params.merge(selling_price: params[:price].to_f + LineItem.calculate_vat(params[:price].to_f, 1)))
    if item.save
      render json: ItemRepresenter.new(item).as_json, status: :created
    else
      render json: item.errors.full_messages, status: :unprocessable_entity
    end
  end

  def update
    if @item.update(item_params.merge(selling_price: params[:price].to_f + LineItem.calculate_vat(params[:price].to_f, 1)))
      render json: ItemRepresenter.new(@item).as_json, status: :ok
    else
      render json: @item.errors.full_messages, status: :unprocessable_entity
    end
  end

  def destroy
    @item.destroy!
    head :no_content
  end

  private

  def item_params
    params.require(:item).permit(:name, :price, :size, :color)
  end

  def set_item
    @item = Item.find(params[:id])
  end
end
