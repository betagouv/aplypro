# frozen_string_literal: true

module ClassesHelper
  def avancement_ribs(classe)
    complete = classe.active_students.filter_map(&:rib).size
    all = classe.active_students.size

    "#{complete}/#{all}"
  end

  def payment_status(pfmp)
    case pfmp.payment_state
    when :blocked
      :warning
    else
      :new
    end
  end
end
