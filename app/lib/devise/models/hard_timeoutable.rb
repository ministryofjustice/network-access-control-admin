# frozen_string_literal: true

module Devise
  module Models
    # HardTimeoutable ensures that users are not signed in for longer then the max
    # sign in duration. When a user has been signed in for longer then configured duration,
    # the user will be asked for credentials again.
    #
    # == Options
    #
    # HardTimeoutable adds the following options to devise_for:
    #
    #   * +hard_timeout_in+: the interval to timeout the user session after sign in
    #
    # == Examples
    #
    #   user.hard_timedout?
    #
    module HardTimeoutable
      extend ActiveSupport::Concern

      def self.required_fields(klass)
        []
      end

      # Checks whether the user session has expired based on configured time.
      def hard_timedout?(signed_in_at)
        hard_timeout_in.present? && signed_in_at.present? && signed_in_at <= hard_timeout_in.ago
      end

      def hard_timeout_in
        self.class.hard_timeout_in
      end

      private

      module ClassMethods
        Devise::Models.config(self, :hard_timeout_in)
      end
    end
  end
end
