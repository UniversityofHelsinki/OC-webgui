# Handle user settings.
class SettingsController < ApplicationController
  DEFAULT_SETTINGS = {
    'colors' => {
      'background' => '#87aade',
      'font' => '#333333',
      'statuses' => {
        'free' => '#37c837',
        'call' => '#ffff4d',
        'busy' => '#ff3333'
      }.freeze
    }.freeze, 'others' => {
      'service_height' => '111'
    }.freeze
  }.freeze

  def get
    if current_user
      render json: DEFAULT_SETTINGS.deep_merge(current_user.settings)
    else
      render json: DEFAULT_SETTINGS
    end
  end

  def check_colors(hash, errors = {})
    hash.each do |key, value|
      if value.is_a? Hash
        new_errors = check_colors(value)
        errors[key] = new_errors unless new_errors.empty?
      elsif /#[0-9a-fA-F]{6}/ !~ value
        errors[key] = 'invalid color'
      end
    end
    errors
  end

  def update
    return render json: { error: 'not logged in' }, status: :unauthorized unless current_user
    new_settings = DEFAULT_SETTINGS.deep_merge(params.permit(colors: [:background, :font, statuses: [:free, :call, :busy]], others: [:service_height]))
    errors = check_colors(new_settings['colors'])
    # check others jne jne
    return render json: { colors: errors }, status: :bad_request unless errors.empty?
    current_user.update(settings: new_settings)
    render json: new_settings
  end
end
