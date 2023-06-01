# frozen_string_literal: true

class Pfmp < ApplicationRecord
  belongs_to :student

  has_many :transitions, class_name: "PfmpTransition", autosave: false, dependent: :destroy

  # Initialize the state machine
  def state_machine
    @state_machine ||= PfmpStateMachine.new(
      self,
      transition_class: PfmpTransition,
      association_name: :transitions
    )
  end
end
