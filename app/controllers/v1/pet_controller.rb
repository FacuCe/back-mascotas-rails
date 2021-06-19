class V1::PetController < ApplicationController
  before_action :check_token, only: [:index, :show, :create, :update, :destroy]
  before_action :check_enabled, only: [:index, :show, :create, :update, :destroy]
  before_action :check_pet, only: [:show, :update, :destroy]

  def index
    pets = current_user.pets.as_json(
      only: [:id, :name, :description],
      methods: [:birthDate]
    )
    render(json: pets, status: 200)
  end

  def show
    render(
      json: current_pet.as_json(
        only: [:id, :name, :description],
        methods: [:birthDate]
      ),
      status: 200
    )
  end

  def create
    pet = current_user.pets.new(pet_params)

    if pet.save
      render(
        json: pet.as_json(
          only: [:id, :name, :description],
          methods: [:birthDate]
        ),
        status: 200
      )
    else
      render(
        json: format_error(request.path, pet.errors.full_messages),
        status: 401
      )
    end
  end

  def update
    if current_pet.update(pet_params)
      render(
        json: current_pet.as_json(
          only: [:id, :name, :description],
          methods: [:birthDate]
        ),
        status: 200
      )
    else
      render(
        json: format_error(request.path, current_pet.errors.full_messages),
        status: 401
      )
    end
  end

  def destroy
    if current_pet.destroy
      render(status: 200)
    else
      render(
        json: format_error(request.path, current_pet.errors.full_messages),
        status: 401
      )
    end
  end

  private

  def current_pet
    @current_pet = current_user.pets.find_by(id: params[:id])
  end

  def check_pet
    return if current_pet.present?

    render(
      json: format_error(request.path, "No existe la moscota con el id #{params[:id]}"),
      status: 401
    )
  end

  def pet_params
    result = params.require(:pet).permit(:name, :description).to_h
    result.merge(birth_date: params['birthDate'])
  end
end
  
