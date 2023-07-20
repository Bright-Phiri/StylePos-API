# frozen_string_literal: true

class Api::V1::CategoriesController < ApplicationController
  before_action :set_category, only: [:show, :show_items, :update, :destroy]
  def index
    categories = Category.all
    render json: categories
  end

  def show
    render json: @category
  end

  def show_items
    if @category.items_count.nil?
      render json: {}, status: :not_found
    else
      items = @category.items
      items = items.paginate(page: params[:page], per_page: params[:per_page])
      render json: { items: ItemsRepresenter.new(items).as_json, total: items.total_entries }
    end
  end

  def create
    category = Category.new(category_params)
    if category.save
      render json: category, status: :created
    else
      render json: category.errors.full_messages, status: :unprocessable_entity
    end
  end

  def update
    if @category.update(category_params)
      render json: @category, status: :ok
    else
      render json: @category.errors.full_messages, status: :unprocessable_entity
    end
  end

  def destroy
    @category.destroy!
    head :no_content
  end

  private

  def category_params
    params.require(:category).permit(:name, :description)
  end

  def set_category
    @category = Category.find(params[:id])
  end
end
