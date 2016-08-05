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
      'sla' => 300,
      'working_day_start' => 8,
      'working_day_end' => 18
    }.freeze
  }.freeze

  def settings
    if current_user
      DEFAULT_SETTINGS.deep_merge(current_user.settings)
    else
      DEFAULT_SETTINGS
    end
  end

  def get
    render json: settings
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

  def check_others(hash, errors = {})
    if hash['working_day_start'] >= hash['working_day_end']
      errors['working_day_start'] = 'työpäivän alku ei voi olla työpäivän lopun jälkeen'
    end
    errors
  end

  def update
    return render json: { error: 'not logged in' }, status: :unauthorized unless current_user
    new_settings = DEFAULT_SETTINGS.deep_merge(params.permit(
      colors: [:background, :font, statuses: [:free, :call, :busy]],
      others: [:sla, :working_day_start, :working_day_end]))
    errors_colors = check_colors(new_settings['colors'])
    errors_others = check_others(new_settings['others'])
    return render json: { colors: errors_colors, others: errors_others }, status: :bad_request unless errors_colors.empty? && errors_others.empty?
    current_user.update(settings: new_settings)
    render json: new_settings
  end
end
