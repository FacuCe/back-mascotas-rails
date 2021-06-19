class V1::ProfileController < ApplicationController
  before_action :check_token, only: [:show, :create, :picture]

  # si el profile no está en el seed, esto no funciona (ya funciona)
  def show
    if current_user.profile.present?
      json = current_user.profile.as_json(
        only: [
          :name,
          :phone,
          :email,
          :address,
          :province_id,
          :picture
        ]
      )

      json[:province] = current_user.profile.province_id

      render(
        json: json,
        status: 200
      )
    else
      render(
        json: format_error(request.path, "No hay profile"),
        status: 401
      )
    end
  end

  def create
    profile = if current_user.profile.present?
                current_user.profile
              else
                Profile.new(user_id: current_user.id) # que diferencia hay con Profile.new(user: current_user)
              end

    profile.assign_attributes(profile_params)

    if profile.save
      render(
        json: profile.as_json(
          only: [
            :name,
            :phone,
            :email,
            :address,
            :province_id,
            :picture
          ]
        ),
        status: 200
      )
    else
      render(
        json: format_error(request.path, profile.errors.full_messages),
        status: 401
      )
    end
  end

  def picture
    if params[:image].present?
      current_user.profile.add_picture!(params[:image])

      render(
        status: 200,
        json: { id: current_user.profile.picture }
      )
    else
      render(
        json: format_error(request.path, "No me mandaste la imagen"),
        status: 401
      )
    end
    
  end

  private

  def profile_params
    attrs = params.require(:profile).permit(
      :name,
      :phone,
      :email,
      :address
    )

    attrs.merge!(province_id: params["province"])
  end
end
