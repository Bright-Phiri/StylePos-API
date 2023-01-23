# frozen_string_literal: true

class Api::V1::EmployeesController < ApplicationController
  before_action :set_employee, only: [:update, :show, :destroy]
  def index
    employees = Employee.all
    render json: employees
  end

  def show
    render json: @employee
  end

  def create
    employee = Employee.new(employee_params)
    if employee.save
      render json: employee, status: :created
    else
      render json: employee.errors.full_messages, status: :unprocessable_entity
    end
  end

  def update
    if @employee.update(employee_params)
      render json: @employee, status: :ok
    else
      render json: @employee.errors.full_messages, status: :unprocessable_entity
    end
  end

  def destroy
    @employee.destroy!
    head :no_content
  end

  private

  def employee_params
    params.require(:employee).permit(:name, :user_name, :job_title, :phone_number, :email, :password, :password_confirmation)
  end

  def set_employee
    @employee = Employee.find(params[:id])
  end
end
