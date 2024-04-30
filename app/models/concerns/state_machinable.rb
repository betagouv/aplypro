# frozen_string_literal: true

module StateMachinable
  extend ActiveSupport::Concern

  included do
    class_eval do
      %w[transition_class state_machine_class transition_relation_name].each do |method_name|
        define_singleton_method(method_name) do
          const_get(method_name.upcase)
        end
      end
    end

    include Statesman::Adapters::ActiveRecordQueries[
      transition_class: transition_class,
      initial_state: state_machine_class.initial_state
    ]

    def state_machine
      @state_machine ||= self.class.state_machine_class.new(self, transition_class: self.class.transition_class,
                                                                  association_name: self.class.transition_relation_name)
    end

    delegate :can_transition_to?,
             :current_state,
             :history,
             :last_transition,
             :last_transition_to,
             :transition_to!,
             :transition_to,
             :in_state?, to: :state_machine
  end
end
