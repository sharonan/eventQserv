class EventPushNotificationMessage


  def self.new_event(event_id,event_title)
    message = {}
    if (!event_id.empty? && !event_title.empty? )

      message =         {:message => {:action => 'invite_to_event',
                          :event_id => event_id,
                            #:event_title => event_title,

      } }
    end
    if (!message.empty?)
      return message.to_json
    else
      return {}
    end
  end



  def self.book_plan(event_id,event_plan_id)
    if (!event_id.empty? && !event_plan_id.empty? )

      message =        {:message => { :action => 'book_plan',
      :event_id => event_id,
      #:event_plan_id => event_plan_id,


    }
      }

    end
    if (!message.empty?)
      return message.to_json
    else
      return {}
    end
  end


  def self.cancel_event(event_id,event_title)
    if (!event_id.empty? && !event_title.empty?  )

      message =        {:message => { :action => 'cancel_event',
      :event_id => event_id,
      #:event_title => event_title,


      }
      }

    end
    if (!message.empty?)
      return message.to_json
    else
      return {}
    end

    end

    def self.new_attendees(event_id)
      if (!event_id.empty? )

        message =        {:message => { :action => 'new_attendees',
                                        :event_id => event_id,


        }
        }

      end
      if (!message.empty?)
        return message.to_json
      else
        return {}
      end
    end

  def self.change_event(event_id)
    if (!event_id.empty? )

      message =        {:message => { :action => 'change_event',
                                      :event_id => event_id,


      }
      }

    end
    if (!message.empty?)
      return message.to_json
    else
      return {}
    end
  end
  def self.edit_plan(event_id,new_event_plan_id)
    if (!event_id.empty? && !new_event_plan_id.nil? && !new_event_plan_id.empty? )

      message =        {:message => { :action => 'edit_plan',
                                      :event_id => event_id,
                                      #:event_plan_id => 'new_event_plan_id'
                                      #:event_plan_ids =>  event_plan_ids

      }
      }

    end
    if (!message.empty?)
      return message.to_json
    else
      return {}
    end
  end
  def self.new_plan(event_id,event_plan_ids)
    if (!event_id.empty? && !event_plan_ids.nil? && !event_plan_ids.empty? )

      message =        {:message => { :action => 'new_plan',
                                      :event_id => event_id,
                                      #:event_plan_ids =>  event_plan_ids

      }
      }

    end
    if (!message.empty?)
      return message.to_json
    else
      return {}
    end
  end

  def self.chat_messages(event_id)
    if (!event_id.empty?)

      message =        {:message => { :action => 'chat_messages',
                                       :event_id => event_id

      }
      }

    end
    if (!message.empty?)
      return message.to_json
    else
      return {}
    end
  end


  def self.event_plan_response(event_id,event_plan_id,status,user_response_id="")
    if (!event_id.empty? && !event_plan_id.empty? && !status.empty?  )

      message =        {:message => { :action => 'event_plan_response',
      :event_id => event_id,
      #:event_plan_id=>event_plan_id,
          #:status => status,
      #:user_response_id => user_response_id

		}
}

    end
    if (!message.empty?)
      return message.to_json
    else
      return {}
    end
  end
  def self.nudge(event_id,phone_number)
    if (!event_id.empty?)

      message =        {:message => { :action => 'nudge',
                                      :event_id => event_id,
                                      :phone_number => phone_number
      }
      }

    end
    if (!message.empty?)
      return message.to_json
    else
      return {}
    end
  end
end
