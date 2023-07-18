# frozen_string_literal: true

class Api::V1::CategoriesController < ApplicationController
  before_action :set_category, only: [:update, :destory]
  def index
    categories = Category.all
    render json: categories
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
