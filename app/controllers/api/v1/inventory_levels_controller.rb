# frozen_string_literal: true

class Api::V1::InventoryLevelsController < ApplicationController
  before_action :set_inventory_level, only: [:update, :show]

  def index
    inventory_levels = InventoryLevel.preload(:item).search(params[:search])
    inventory_levels = inventory_levels.paginate(page: params[:page], per_page: params[:per_page])
    render json: { inventory_levels: InventoriesRepresenter.new(inventory_levels).as_json, total: inventory_levels.total_entries }
  end

  def show
    render json: InventoryRepresenter.new(@inventory_level).as_json
  end

  def create
    item = Item.find(params[:item_id])
    raise ExceptionHandler::InventoryLevelError, 'Inventory level already exists' unless item.inventory_level.nil?

    inventory_level = item.create_inventory_level(inventory_level_params)
    if inventory_level.new_record?
      render json: inventory_level.errors.full_messages, status: :unprocessable_entity
    else
      render json: InventoryRepresenter.new(inventory_level).as_json, status: :created
    end
  end

  def update
    if @inventory_level.update(inventory_level_params)
      render json: InventoryRepresenter.new(@inventory_level).as_json, status: :ok
    else
      render json: @inventory_level.errors.full_messages, status: :unprocessable_entity
    end
  end

  def destroy
    InventoryLevel.find(params[:id]).destroy!
    head :no_content
  end

  private

  def inventory_level_params
    params.require(:inventory_level).permit(:quantity, :supplier)
  end

  def set_inventory_level
    @inventory_level = InventoryLevel.find(params[:id])
  end
end
