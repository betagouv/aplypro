# frozen_string_literal: true

module StateMachinable
  extend ActiveSupport::Concern

  included do
    include Statesman::Adapters::ActiveRecordQueries[
      transition_class: TRANSITION_CLASS,
      initial_state: STATE_MACHINE_CLASS.initial_state,
    ]

    def state_machine
      @state_machine ||= STATE_MACHINE_CLASS.new(self, transition_class: TRANSITION_CLASS)
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
