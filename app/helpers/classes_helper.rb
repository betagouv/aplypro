# frozen_string_literal: true

module ClassesHelper
  def avancement_ribs(classe)
    complete = classe.students.filter_map(&:rib).size
    all = classe.students.size

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
