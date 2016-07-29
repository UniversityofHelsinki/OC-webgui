# Handle user settings.
class SettingsController < ApplicationController
  DEFAULT_SETTINGS = {
    'colors': {
      'background': '#87aade',
      'font': '#333333'
    }
  }

  def get
    if current_user
      render json: DEFAULT_SETTINGS.deep_merge(current_user.settings)
    else
      render json: DEFAULT_SETTINGS
    end
  end

  def update
    return render json: { error: 'not logged in' }, status: :unauthorized unless current_user
    new_settings = params.permit(colors: [:background, :font])
    current_user.update(settings: new_settings)
    render json: new_settings
  end
end
