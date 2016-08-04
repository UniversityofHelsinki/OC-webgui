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
      'service_height' => '300',
      'working_day_start' => '8',
      'working_day_end' => '18'
    }.freeze
  }.freeze

  def get_settings
    if current_user
      DEFAULT_SETTINGS.deep_merge(current_user.settings)
    else
      DEFAULT_SETTINGS
    end
  end

  def get
    render json: get_settings
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
    new_settings = DEFAULT_SETTINGS.deep_merge(params.permit(colors: [:background, :font, statuses: [:free, :call, :busy]], others: [:service_height, :working_day_start, :working_day_end]))
    errors = check_colors(new_settings['colors'])
    return render json: { colors: errors }, status: :bad_request unless errors.empty?
    current_user.update(settings: new_settings)
    render json: new_settings
  end
end
