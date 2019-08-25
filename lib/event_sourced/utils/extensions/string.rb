# frozen_string_literal: true

class String
  def dotcase
    gsub(/::/, '.')
      .gsub(/([A-Z]+)([A-Z][a-z])/, '\1.\2')
      .gsub(/([a-z\d])([A-Z])/, '\1.\2')
      .tr('-', '.')
      .tr('_', '.')
      .downcase
  end

  def snakecase
    gsub(/::/, '/')
      .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      .gsub(/([a-z\d])([A-Z])/, '\1_\2')
      .tr('-', '_')
      .downcase
  end
end
