# frozen_string_literal: true

class Api::V1::EmployeesController < ApplicationController
  skip_before_action :require_login, only: :set_manager
  before_action :set_employee, only: [:update, :show, :destroy, :disable_user, :activate_user]
  def index
    employees = Employee.where.not(job_title: 'Store Manager')
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

  def set_manager
    if Employee.exists?
      render json: { message: 'Access Denied: You do not have the required privileges to complete this action.' }, status: :forbidden
    else
      user = Employee.new(employee_params.merge(job_title: 'Store Manager'))
      if user.save
        render json: user, status: :created
      else
        render json: user.errors.full_messages, status: :unprocessable_entity
      end
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

  def disable_user
    @employee.status = 1
    @employee.save(validate: false)
    render json: {}, status: :ok
  end

  def activate_user
    @employee.status = 0
    @employee.save(validate: false)
    render json: {}, status: :ok
  end

  private

  def employee_params
    params.require(:employee).permit(:first_name, :last_name, :user_name, :job_title, :phone_number, :email, :password, :password_confirmation)
  end

  def set_employee
    @employee = Employee.find(params[:id])
  end
end
