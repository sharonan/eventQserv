class TextMessages
  @@link =  (Rails.env.production?)?  "http://clowder.me" :   "http://clowder.me/devdevdev"
  #SMS: INVITATION TO NON-CLOWDER USER
  #[Firstname ] [Lastname ] invited you to meet. Download Clowder to get together: bit.ly/[link]
  def self.get_invitation_to_non_user_sms(first_name, last_name)

    sms_message = ""
    if (!first_name.nil? && !first_name.empty? && !last_name.nil? && !last_name.empty?)
      sms_message =  "#{first_name} #{last_name} invited you to meet. Download Clowder to get together: #{@@link}"
    end

    return sms_message
  end

  #Your 3-digit code: [CODE]. Or tap this link and we'll enter it for you: clowder://[CODE] .
  def self.get_verification_sms(code)

    sms_message = ""
    if (!code.nil? && !code.empty? )
      sms_message =  "Your 3-digit code: #{code}. Or tap this link and we'll enter it for you: clowder://#{code}."
    end

    return sms_message
  end

  #PUSH: NEW EVENT INVITATION
  #[Firstname ] [Lastname ] invited you to “[EVENT NAME]”.
  def self.get_new_event_invitation_push(first_name, last_name, event_title)

    sms_message = ""
    if (!first_name.nil? && !first_name.empty? && !last_name.nil? && !last_name.empty? && !event_title.nil? && !event_title.empty?)
      sms_message =  "#{first_name} #{last_name} invited you to '#{event_title}'"
    end

    return sms_message
  end
  #PUSH: NEW PLAN
  #[Firstname ] added a new plan to “[EVENT NAME]”.
  def self.get_new_plan_push(first_name,  event_title)

    sms_message = ""
    if (!first_name.nil? && !first_name.empty? &&  !event_title.nil? && !event_title.empty?)
      sms_message =  "#{first_name} added a new plan to '#{event_title}'"
    end

    return sms_message
  end

  #PUSH: EDIT PLAN
  #[Firstname ] made a change to a plan in “[EVENT NAME]”.
  def self.get_edit_plan_push(first_name,  event_title)

    sms_message = ""
    if (!first_name.nil? && !first_name.empty? &&  !event_title.nil? && !event_title.empty?)
      sms_message =  "#{first_name} made a change to a plan in '#{event_title}'"
    end

    return sms_message
  end


  #PUSH: CHAT MESSAGE
  #James: “Hey guys, I hate pizza.”
  def self.get_chat_message_push(first_name,message)

    sms_message = ""
    if (!message.nil? && !message.empty? && !first_name.nil? && !first_name.empty?)
      sms_message =  "#{first_name}: '#{message}.'"
    end

    return sms_message
  end

  #PUSH: EVENT CANCELLED
  #[OrganizerFirstName] has unbooked [EventName]. Voting is now back open!
  def self.get_cancelled_event_push(first_name,event_title)

    sms_message = ""
    if (!event_title.nil? && !event_title.empty? && !first_name.nil? && !first_name.empty?)
      sms_message =  "#{first_name} has unbooked '#{event_title}'. Voting is back open!"
    end

    return sms_message
  end

  #PUSH: EVENT BOOKED
  #Good news everyone! You’re booked for “[EVENT NAME]”! Feel free to keep chatting until the event starts.
  def self.get_booked_event_push(event_title)
    puts "#{event_title }alert"

    sms_message = ""
    if (!event_title.nil? && !event_title.empty? )
      sms_message =  "Good news everyone! You are booked for '#{event_title}'! Feel free to keep chatting until the event starts."
    end

    return sms_message
  end

  #PUSH: EVENT BOOKED
  #Good news everyone! You’re booked for “[EVENT NAME]”! Feel free to keep chatting until the event starts.
  def self.get_new_attendees_push(event_title)
    puts "#{event_title }alert"

    sms_message = ""
    if (!event_title.nil? && !event_title.empty? )
      sms_message =  "New Attendees were added to '#{event_title}'."
    end

  end
  #[Firstname] nudged you. Go vote on [Event Title]!
  def self.get_nudge_notification(first_name,event_title)
    sms_message = ""
    if (!event_title.nil? && !event_title.empty? && !first_name.nil? && !first_name.empty?)
      sms_message =  "#{first_name} nudged you. Go vote on '#{event_title}'!"
    end

    return sms_message
  end
end
