# frozen_string_literal: true

class Api::V1::ReceivedItemsController < ApplicationController
  before_action :set_received_item, only: [:show, :update, :destroy]

  def index
    received_items = ReceivedItem.preload(:item).search(params[:search])
    received_items = received_items.paginate(page: params[:page], per_page: params[:per_page])
    render json: { items: ReceivedItemsRepresenter.new(received_items).as_json, total: received_items.total_entries }
  end

  def show
    render json: ReceivedItemRepresenter.new(@received_item).as_json
  end

  def create
    item = Item.find(params[:item_id])
    received_item = item.received_items.build(received_item_params)
    if received_item.save
      render json: ReceivedItemRepresenter.new(received_item).as_json, status: :created
    else
      render json: received_item.errors.full_messages, status: :unprocessable_entity
    end
  end

  def update
    if @received_item.update(received_item_params)
      render json: ReceivedItemRepresenter.new(@received_item).as_json, status: :ok
    else
      render json: @received_item.errors.full_messages, status: :unprocessable_entity
    end
  end

  def destroy
    @received_item.destroy!
    head :no_content
  end

  private

  def received_item_params
    params.require(:received_item).permit(:quantity, :batch_number, :supplier, :cost_price, :selling_price)
  end

  def set_received_item
    @received_item = ReceivedItem.find(params[:id])
  end
end
